CREATE TABLE [dbo].[Server](
       [ServerID] [int] IDENTITY(1000,1) NOT NULL,
       [HostID] [int] NOT NULL,
       [ClusterID] [int] NULL,
       [InstanceName] [varchar](128) NOT NULL,
       [ComputerNamePhysicalNetBIOS] [varchar](128) NULL,
       [DomainInstanceName] [varchar](128) NULL,
       [ClusterName] [varchar](128) NULL,
       [IsClustered] [bit] NULL,
       [Environment] [char](1) NULL,
       [Edition] [varchar](128) NULL,
       [Version] [varchar](25) NULL,
       [Product] [varchar](128) NOT NULL,
       [ProductLevel] [varchar](12) NULL,
       [Platform] [varchar](128) NULL,
       [Collation] [varchar](128) NULL,
       [tcpEnabled] [bit] NULL,
       [tcpName] [varchar](128) NULL,
       [tcpPort] [varchar](15) NULL,
       [NamedPipesEnabled] [bit] NULL,
       [NamedPipesName] [varchar](128) NULL,	
       [DefaultFile] [varchar](256) NULL,
       [DefaultLog] [varchar](256) NULL,
       [ErrorLogPath] [varchar](256) NULL,
       [MasterDbLogPath] [varchar](256) NULL,
       [MasterDbPath] [varchar](256) NULL,
       [BackupDirectory] [varchar](256) NULL,
       [ServiceAccount] [varchar](128) NULL,
       [ServiceStartMode] [varchar](128) NULL,
       [BrowserServiceAccount] [varchar](128) NULL,
       [BrowserStartMode] [varchar](128) NULL,
       [LoginMode] [varchar](128) NULL,
       [NumberOfLogFiles] [varchar](128) NULL,
       [ResourceLastUpdateDate] [smalldatetime] NULL,
       [CreateDate] [smalldatetime] NOT NULL,
       [UpdateDate] [smalldatetime] NOT NULL,
       [Active] [bit] NOT NULL,
 CONSTRAINT [PK_Server] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

------------------------------------------------------------------------
CREATE TRIGGER [dbo].[trServerChangeLog] ON [dbo].[Server]
   FOR INSERT, UPDATE, DELETE
   
AS

SET NOCOUNT ON 

DECLARE @bit INT ,
        @field INT ,
        @maxfield INT ,
        @char INT ,
        @fieldname VARCHAR(128) ,
        @TableName VARCHAR(128) ,
        @PKCols VARCHAR(1000) ,
        @sql VARCHAR(7000), 
        @UpdateDate VARCHAR(21) ,
        @UserName VARCHAR(128),
        @HostName VARCHAR(128),
        @Type CHAR(1) ,
        @PKSelect VARCHAR(1000)

--You will need to change @TableName to match the table to be audited
SELECT @TableName = 'Server'

-- date and user
SELECT @UserName = SYSTEM_USER,
       @HostName = HOST_NAME(),
       @UpdateDate = CONVERT(VARCHAR(8), GETDATE(), 112) +' ' + CONVERT(VARCHAR(12), GETDATE(), 114)

-- Action
IF EXISTS (SELECT * FROM inserted)
   IF EXISTS (SELECT * FROM deleted)
      SELECT @Type = 'U'
   ELSE
      SELECT @Type = 'I'
ELSE
      SELECT @Type = 'D'

-- get list of columns
SELECT * INTO #ins FROM inserted
SELECT * INTO #del FROM deleted

-- Get primary key columns for full outer join
SELECT @PKCols = COALESCE(@PKCols + ' AND', ' ON') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk
 INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE c ON c.TABLE_NAME = pk.TABLE_NAME AND
       c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
 WHERE pk.TABLE_NAME = @TableName AND
       CONSTRAINT_TYPE = 'PRIMARY KEY'

-- Get primary key select for insert
SELECT @PKSelect = COALESCE(@PKSelect+'+','') + '''<' + COLUMN_NAME + '=''+CONVERT(varchar(100),COALESCE(i.' + COLUMN_NAME +',d.' + COLUMN_NAME + '))+''>'''
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk
 INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE c ON c.TABLE_NAME = pk.TABLE_NAME AND
       c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
 WHERE pk.TABLE_NAME = @TableName AND
       CONSTRAINT_TYPE = 'PRIMARY KEY'

IF @PKCols IS NULL
   BEGIN
   RAISERROR('no PK on table %s', 16, -1, @TableName)
   RETURN
END

SELECT @field = 0,
       @maxfield = MAX(ORDINAL_POSITION) 
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_NAME = @TableName

WHILE @field < @maxfield
      BEGIN
      SELECT @field = MIN(ORDINAL_POSITION) 
        FROM INFORMATION_SCHEMA.COLUMNS 
       WHERE TABLE_NAME = @TableName AND 
             ORDINAL_POSITION > @field
      SELECT @bit = (@field - 1 )% 8 + 1
      SELECT @bit = POWER(2,@bit - 1)
      SELECT @char = ((@field - 1) / 8) + 1

      IF SUBSTRING(COLUMNS_UPDATED(),@char, 1) & @bit > 0 OR @Type IN ('I','D')
         BEGIN
         SELECT @fieldname = COLUMN_NAME 
           FROM INFORMATION_SCHEMA.COLUMNS 
          WHERE TABLE_NAME = @TableName AND
                ORDINAL_POSITION = @field

         SELECT @sql = 'INSERT dbo.ChangeLog ( '+ CHAR(10)+
                       '       ExecutedAction,'+ CHAR(10)+
                       '       TableName,'+ CHAR(10)+
                       '       PK,'+ CHAR(10)+
                       '       FieldName,'+ CHAR(10)+
                       '       OldValue,'+ CHAR(10)+
                       '       NewValue,'+ CHAR(10)+
                       '       UpdateDate,'+ CHAR(10)+
                       '       UserName,'+ CHAR(10)+
                       '       ExecutedFrom)'+ CHAR(10)+
                       'SELECT '''+ @Type +''','+ CHAR(10)+
                       '       '''+ @TableName +''',' + @PKSelect +','+ CHAR(10)+
                       '       '''+ @fieldname + ''','+ CHAR(10)+
                       '        CONVERT(varchar(1000),d.' + @fieldname + '),'+ CHAR(10)+
                       '        CONVERT(varchar(1000),i.' + @fieldname + '),'+ CHAR(10)+
                       '        '''+ @UpdateDate +''','+ CHAR(10)+
                       '        '''+ @UserName +''','+ CHAR(10)+
                       '        '''+ @HostName +''''+ CHAR(10)+
                       '  FROM #ins i'+ CHAR(10)+
                       '  FULL OUTER JOIN #del d'+ @PKCols + CHAR(10)+
                       ' WHERE i.' + @fieldname + ' <> d.' + @fieldname + CHAR(10)+
                       '    OR (i.' + @fieldname + ' is NULL AND  d.' + @fieldname + ' is NOT NULL)' + CHAR(10)+
                       '    OR (i.' + @fieldname + ' is NOT NULL AND  d.' + @fieldname + ' is NULL)' 


         EXEC (@sql)
      END --END IF
END --END WHILE
GO

ALTER TABLE [dbo].[Server] ENABLE TRIGGER [trServerChangeLog]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID of the SQL Server.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'ServerID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains the ID of the standalone host of the SQL Server. Null if the server is on a cluster.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'HostID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'MSSQLSRVER for the default instance. For a named instance, instanceName = serverName.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'InstanceName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Collation of the SQL Server.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'Collation'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Status of this server. Possible values include D (Development), Q (Quality Assurance), P (Production), U (User Acceptance Testing), I (Integration), R (Disaster Recovery).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'Environment'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Network protocols used by the SQL server.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'tcpEnabled'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TCP port on which the SQL Server is listening.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'tcpPort'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Enterprise, Standard, or Developer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'Edition'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'10.0.1300' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'Version'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Service pack installed on the SQL Server.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'Product'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Path to the SQL Server Errorlog.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'ErrorLogPath'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Path to the directory that contains system databases.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'MasterDbPath'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time the server record was created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time the server record was last updated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Server', @level2type=N'COLUMN',@level2name=N'UpdateDate'
GO


