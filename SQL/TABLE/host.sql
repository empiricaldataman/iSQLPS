CREATE TABLE [dbo].[Host](
	[HostID] [int] IDENTITY(1000,1) NOT NULL,
	[HostName] [varchar](128) NOT NULL,
	[location] [char](2) NOT NULL,
	[Description] [varchar](500) NULL,
	[PrimaryBU] [varchar](128) NOT NULL,
	[TimeZone] [varchar](128) NULL,
	[EnableDaylightSavingsTime] [bit] NULL,
	[Domain] [varchar](128) NULL,
	[Manufacturer] [varchar](128) NULL,
	[Model] [varchar](128) NULL,
	[SystemType] [varchar](128) NULL,
	[SystemStartupOptions] [varchar](128) NULL,
	[NumberOfProcessors] [tinyint] NULL,
	[NumberOfLogicalProcessors] [tinyint] NULL,
	[NumberOfCores] [tinyint] NULL,
	[ProcessorType] [varchar](128) NULL,
	[TotalPhysicalMemory] [bigint] NULL,
	[CountryCode] [varchar](128) NULL,
	[LastBootUpTime] [smalldatetime] NULL,
	[Locale] [varchar](128) NULL,
	[OS] [varchar](128) NULL,
	[Version] [varchar](128) NULL,
	[ServicePackMajorVersion] [varchar](10) NULL,
	[ServicePackMinorVersion] [varchar](10) NULL,
	[BuildNumber] [varchar](20) NULL,
	[InstallDate] [datetime] NULL,
	[TotalVisibleMemorySize] [bigint] NULL,
	[TotalVirtualMemorySize] [bigint] NULL,
	[PagingFileSize] [bigint] NULL,
	[IP1] [varchar](128) NULL,
	[IP2] [varchar](128) NULL,
	[IP3] [varchar](128) NULL,
	[IP4] [varchar](128) NULL,
	[IP5] [varchar](128) NULL,
	[IP6] [varchar](128) NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateDate] [smalldatetime] NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_Host] PRIMARY KEY CLUSTERED 
(
	[HostID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_HostName] UNIQUE NONCLUSTERED 
(
	[HostName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Host] ADD  DEFAULT ((1)) FOR [Active]
GO

------------------------------------------------------------------------
CREATE TRIGGER [dbo].[trHostChangeLog] ON [dbo].[Host]
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
SELECT @TableName = 'Host'

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

ALTER TABLE [dbo].[Host] ENABLE TRIGGER [trHostChangeLog]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID of the host and the primary key.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'HostID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the SQL Server host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'HostName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code of the city in which the SQL host is located (eg., NY for New York, CH for Chicago).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'location'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of purposes of the SQL Server host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary business unit that owns the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'PrimaryBU'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standard time zone of the host' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'TimeZone'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicates if daylight saving time (DST) is enabled on the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'EnableDaylightSavingsTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Domain of the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'Domain'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the host''s computer manufacturer (eg., Dell, HP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'Manufacturer'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Product name that the manufacturer gives to the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'Model'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System running on the Windows-based computer (eg., X86-based PC, 64-bit Intel PC).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'SystemType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of the options for starting up the computer system running Windows.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'SystemStartupOptions'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of logical processors available on the computer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'NumberOfProcessors'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of physical processors available on the computer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'NumberOfLogicalProcessors'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total size fo physical memory.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'TotalPhysicalMemory'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Country code that the host uses.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'CountryCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time the host was last restarted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'LastBootUpTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Language identifier used by the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'Locale'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Operating system used by the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'OS'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version number of the operating system.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'Version'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Major version number of the service pack of the OS installed on the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'ServicePackMajorVersion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Minor version number of the service pack of the OS installed on the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'ServicePackMinorVersion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Build number of an operating system.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'BuildNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When the host was first built ore rebuilt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'InstallDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number, in kilobytes, of physical memory available to the operating system. This value does not necessarily indicate the true amount of physical memory, but what is reported to the operating system as available to it.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'TotalVisibleMemorySize'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number, in kilobytes, of virtual memory.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'TotalVirtualMemorySize'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Total number of kilobytes that can be stored in the operating system paging files - 0 indicates that there are no paging files.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'PagingFileSize'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IP Address 1 used by the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'IP1'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IP Address 2 used by the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'IP2'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IP Address 3 used by the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'IP3'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IP Address 4 used by the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'IP4'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IP Address 5 used by the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'IP5'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IP Address 6used by the host.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'IP6'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time the host record was created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time the host record was last updated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host', @level2type=N'COLUMN',@level2name=N'UpdateDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The Hosts table contains information about all the SQL server hosts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Host'
GO
