IF OBJECT_ID(N'dbo.DatabaseFile','U') IS NOT NULL
   DROP TABLE [dbo].[DatabaseFile]
GO

---------------------------------------------------------------------
--    TABLE NAME : dbo.DatabaseFile
--   DESCRIPTION : TableDescriptionAndPurposeGoesHere
----------------------------------------------------------------------
--  POPULATED BY : ReplicationOrDTSPackageOrStoredProcAreValidValues
--  DAYS TO KEEP :
--   MAINTENANCE : N/A
--     EXISTS IN : SERVERNAME.DataBaseName
----------------------------------------------------------------------
-- CHANGE HISTORY:
-- PROJ#    DATE        MODIFIED   DESCRIPTION   
----------------------------------------------------------------------
--          08.08.2010  SYoung     Initial creation.
----------------------------------------------------------------------
CREATE TABLE [dbo].[DatabaseFile](
	[DatabaseFileID] [int] IDENTITY(500000,1) NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[FileName] [varchar](128) NOT NULL,
	[FilePath] [varchar](256) NOT NULL,
	[FileSize] [int] NOT NULL,
	[UsedSpace] [int] NULL,
	[FileGrowth] [int] NULL,
	[FileGrowthType] [char](10) NULL,
	[FileMaxSize] [bigint] NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[Active] [tinyint] NOT NULL,
 CONSTRAINT [PK_DatabaseFile] PRIMARY KEY NONCLUSTERED 
(
	[DatabaseFileID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_DatabaseFile_DatabaseID_FileName_FilePath] ON [dbo].[DatabaseFile] 
(
	[DatabaseID] ASC,
	[FileName] ASC,
	[FilePath] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)

CREATE NONCLUSTERED INDEX [idx_DatabaseFile_DatabaseID_FileName_FilePath_FileSize_UsedSpace_FileGrowth_FileGrowthType_FileMaxSize] ON [dbo].[DatabaseFile] 
(
	[DatabaseID] ASC,
	[FileName] ASC,
	[FilePath] ASC,
	[FileSize] ASC,
	[UsedSpace] ASC,
	[FileGrowth] ASC,
	[FileGrowthType] ASC,
	[FileMaxSize] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO

ALTER TABLE [dbo].[DatabaseFile] ADD  CONSTRAINT [DF_DatabaseFile_Active]  DEFAULT ((0)) FOR [Active]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique identifier for the DatabaseFile table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile', @level2type=N'COLUMN',@level2name=N'DatabaseFileID'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique identifier from the Database table and used on this table as a Foreign Key. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile', @level2type=N'COLUMN',@level2name=N'DatabaseID'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Logical name of the data or log file(s).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile', @level2type=N'COLUMN',@level2name=N'FileName'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'File path including file name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile', @level2type=N'COLUMN',@level2name=N'FilePath'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The current size of the dat file in KB.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile', @level2type=N'COLUMN',@level2name=N'FileSize'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The amount of used space in the data file in KB.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile', @level2type=N'COLUMN',@level2name=N'UsedSpace'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The growth increment for the data file in KB or percent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile', @level2type=N'COLUMN',@level2name=N'FileGrowth'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The growth type for the data file in kilobytes or percent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile', @level2type=N'COLUMN',@level2name=N'FileGrowthType'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The maximum size to which the data file can grow in KB.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile', @level2type=N'COLUMN',@level2name=N'FileMaxSize'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The DatabaseFile table contains information about the drives on each MS SQL server.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseFile'
GO



CREATE TRIGGER [dbo].[trDatabaseFileChangeLog] ON [dbo].[DatabaseFile]
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
SELECT @TableName = 'DatabaseFile'
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
                       '        CONVERT(varchar(1000),d.' + @Fieldname + '),'+ CHAR(10)+
                       '        CONVERT(varchar(1000),i.' + @Fieldname + '),'+ CHAR(10)+
                       '        '''+ @UpdateDate +''','+ CHAR(10)+
                       '        '''+ @UserName +''','+ CHAR(10)+
                       '        '''+ @HostName +''''+ CHAR(10)+
                       '  FROM #ins i'+ CHAR(10)+
                       '  FULL OUTER JOIN #del d'+ @PKCols + CHAR(10)+
                       ' WHERE i.' + @Fieldname + ' <> d.' + @Fieldname + CHAR(10)+
                       '    OR (i.' + @Fieldname + ' is NULL AND  d.' + @Fieldname + ' is NOT NULL)' + CHAR(10)+
                       '    OR (i.' + @Fieldname + ' is NOT NULL AND  d.' + @Fieldname + ' is NULL)' 


         EXEC (@Sql)
      END --END IF
END --END WHILE

GO

