IF OBJECT_ID(N'dbo.Database','U') IS NOT NULL
   DROP TABLE [dbo].[Database]
GO

---------------------------------------------------------------------
--    TABLE NAME : dbo.Database
--   DESCRIPTION : TableDescriptionAndPurposeGoesHere
----------------------------------------------------------------------
--  POPULATED BY : ReplicationOrDTSPackageOrStoredProcAreValidValues
--  DAYS TO KEEP :
--   MAINTENANCE : Self cleaning process ....
--    REPLICATED : NO
--     EXISTS IN : SERVERNAME.DataBaseName
----------------------------------------------------------------------
-- CHANGE HISTORY:
-- PROJ#    DATE        MODIFIED   DESCRIPTION   
----------------------------------------------------------------------
--          08.08.2010  SYoung     Initial creation.
----------------------------------------------------------------------
CREATE TABLE [dbo].[Database](
       [DatabaseID] [int] IDENTITY(300000,1) NOT NULL
     , [ServerSQLID] [int] NOT NULL
     , [DatabaseName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
     , [db_id] TINYINT NULL
     , [Owner] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
     , [DataSpaceUsage] int NULL 
     , [IndexSpaceUsage] int NULL
     , [DatabaseSize] int NULL
     , [SpaceAvailable] int NULL
     , [PrimaryFilePath] VARCHAR(500) NULL
     , [IsFullTextEnabled] BIT NULL
     , [Collation] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
     , [RecoveryModel] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
     , [CompatibilityLevel] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
     , [EncryptionEnabled] BIT NULL
     , [PageVerify] VARCHAR(16) NULL
     , [DatabaseOwnershipChaining] BIT NULL
     , [AutoClose] BIT NULL
     , [AutoCreateStatisticsEnabled] BIT NULL
     , [AutoShrink] BIT NULL
     , [AutoUpdateStatisticsAsync] BIT NULL
     , [AutoUpdateStatisticsEnabled] BIT NULL
     , [LastBackup] [smalldatetime] NULL
     , [LastDifferentialBackup] [smalldatetime] NULL
     , [LastLogBackup] [smalldatetime] NULL
     , [DBCreateDate] [smalldatetime] NULL
     , [CreateDate] [smalldatetime] NOT NULL
     , [UpdateDate] [smalldatetime] NOT NULL
     , [Active] [tinyint] NOT NULL
 CONSTRAINT [PK_databaseID] PRIMARY KEY CLUSTERED 
(
	[DatabaseID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_Database_ServerID_DatabaseName] ON [dbo].[Database] 
(
	[ServerSQLID] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO

ALTER TABLE [dbo].[Database] ADD  CONSTRAINT [DF_Database_Active]  DEFAULT ((0)) FOR [Active]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID of the database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'DatabaseID'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID of the server that hosts the database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'ServerSQLID'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'DatabaseName'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Database owner.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'Owner'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Database recovery model.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'RecoveryModel'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the last full backup.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'LastBackup'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the last differential backup.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'LastDifferentialBackup'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the last transaction log backup.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'LastLogBackup'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time the database record was created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'CreateDate'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time the database record was last updated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'UpdateDate'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'On/Off switch to know if the row should be included in queries.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database', @level2type=N'COLUMN',@level2name=N'Active'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Database table contains information about MS SQL databases Data in this table is collected via PowerShell by executing Upsert-Database.ps1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Database'
GO


CREATE TRIGGER [dbo].[trDatabaseChangeLog] ON [dbo].[Database]
  FOR INSERT, UPDATE, DELETE
   
AS

SET NOCOUNT ON 

DECLARE @Bit INT ,
        @Field INT ,
        @MaxField INT ,
        @Char INT ,
        @Fieldname VARCHAR(128) ,
        @TableName VARCHAR(128) ,
        @Schema VARCHAR(128) , 
        @PKCols VARCHAR(1000) ,
        @Sql VARCHAR(7000), 
        @UpdateDate VARCHAR(21) ,
        @UserName VARCHAR(128),
        @HostName VARCHAR(128),
        @Type CHAR(1) ,
        @PKSelect VARCHAR(1000)

--You will need to change @TableName to match the table to be audited
SELECT @TableName = 'Database'
     , @schema = 'dbo'

-- date and user
SELECT @UserName = SYSTEM_USER,
       @HostName = HOST_NAME(),
       @UpdateDate = CONVERT(VARCHAR(8), GETDATE(), 112) +' ' + CONVERT(VARCHAR(12), GETDATE(), 114)

-- Action
IF EXISTS (SELECT 'TRUE' FROM inserted)
   IF EXISTS (SELECT 'TRUE' FROM deleted)
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
       c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME AND
       c.CONSTRAINT_SCHEMA = pk.CONSTRAINT_SCHEMA
 WHERE pk.TABLE_NAME = @TableName AND
       CONSTRAINT_TYPE = 'PRIMARY KEY'

-- Get primary key select for insert
SELECT @PKSelect = COALESCE(@PKSelect+'+','') +' CONVERT(varchar(100),COALESCE(i.' + COLUMN_NAME +', d.' + COLUMN_NAME + '))'
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk
 INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE c ON c.TABLE_NAME = pk.TABLE_NAME AND
       c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME AND
       c.CONSTRAINT_SCHEMA = pk.CONSTRAINT_SCHEMA
 WHERE pk.TABLE_NAME = @TableName AND
       CONSTRAINT_TYPE = 'PRIMARY KEY'

IF @PKCols IS NULL
   BEGIN
   RAISERROR('no PK on table %s', 16, -1, @TableName)
   RETURN
END

SELECT @Field = 0,
       @MaxField = MAX(ORDINAL_POSITION) 
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_NAME = @TableName
   AND [TABLE_SCHEMA] = @Schema

WHILE @Field < @MaxField
      BEGIN
      SELECT @Field = MIN(ORDINAL_POSITION) 
        FROM INFORMATION_SCHEMA.COLUMNS 
       WHERE TABLE_NAME = @TableName AND 
             [TABLE_SCHEMA] = @Schema AND 
             ORDINAL_POSITION > @Field
      SELECT @Bit = (@Field - 1 )% 8 + 1
      SELECT @Bit = POWER(2,@Bit - 1)
      SELECT @Char = ((@Field - 1) / 8) + 1

      IF SUBSTRING(COLUMNS_UPDATED(),@Char, 1) & @Bit > 0 OR @Type IN ('I','D')
         BEGIN
         SELECT @Fieldname = COLUMN_NAME 
           FROM INFORMATION_SCHEMA.COLUMNS 
          WHERE TABLE_NAME = @TableName AND
                [TABLE_SCHEMA] = @Schema AND
                ORDINAL_POSITION = @Field

         SELECT @Sql = 'INSERT ChangeLog ( '+ CHAR(10)+
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
                       '       '''+ @Fieldname + ''','+ CHAR(10)+
                       '       CONVERT(varchar(1000),d.' + @Fieldname + '),'+ CHAR(10)+
                       '       CONVERT(varchar(1000),i.' + @Fieldname + '),'+ CHAR(10)+
                       '       '''+ @UpdateDate +''','+ CHAR(10)+
                       '       '''+ @UserName +''','+ CHAR(10)+
                       '       '''+ @HostName +''''+ CHAR(10)+
                       '  FROM #ins i'+ CHAR(10)+
                       '  FULL OUTER JOIN #del d'+ @PKCols + CHAR(10)+
                       ' WHERE i.' + @Fieldname + ' <> d.' + @Fieldname + CHAR(10)+
                       '    OR (i.' + @Fieldname + ' is NULL AND  d.' + @Fieldname + ' is NOT NULL)' + CHAR(10)+
                       '    OR (i.' + @Fieldname + ' is NOT NULL AND  d.' + @Fieldname + ' is NULL)' 


         --SELECT  @SQL
         EXEC (@Sql)
      END --END IF
END --END WHILE

GO
