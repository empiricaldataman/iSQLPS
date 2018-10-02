IF OBJECT_ID(N'dbo.pIU_Database','P') IS NOT NULL
   DROP PROCEDURE pIU_Database
GO

------------------------------------------------------------------------------------
--  PROCEDURE NAME: dbo.pIU_Database    
--     DESCRIPTION: Inserts or updates a record in the Database table
------------------------------------------------------------------------------------
--   REFERENCED BY: Database.ps1
--    PROJECT NAME: iSQLPS
------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- DATE        MODIFIED   DESCRIPTION   
------------------------------------------------------------------------------------
-- 08.10.2010  SYoung     Initial creation
-- 09.18.2014  SYoung     Add more properties to capture
------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[pIU_Database]
       @ServerID int
     , @DatabaseName varchar(128)
     , @DatabaseID int
     , @Owner varchar(128)
     , @Collation varchar(128)
     , @RecoveryModel char(10)
     , @CompatibilityLevel char(12)
     , @LastBackup smalldatetime
     , @LastDifferentialBackup smalldatetime
     , @LastLogBackup smalldatetime
     , @DBCreateDate smalldatetime
     , @DataSpaceUsage numeric(19,3) NULL
     , @IndexSpaceUsage numeric(19,3) NULL
     , @DatabaseSize numeric(19,3) NULL
     , @SpaceAvailable numeric(19,3) NULL
     , @PrimaryFilePath VARCHAR(500)
     , @IsFullTextEnabled BIT
     , @PageVerify VARCHAR(16)
     , @DatabaseOwnershipChaining BIT
     , @EncryptionEnabled BIT
     , @AutoClose BIT
     , @AutoCreateStatisticsEnabled BIT
     , @AutoShrink BIT
     , @AutoUpdateStatisticsAsync BIT
     , @AutoUpdateStatisticsEnabled BIT
     , @Active tinyint = 1
              
AS

SET NOCOUNT ON

DECLARE @ERRORCODE int, 
        @ERRMSG varchar(128)

IF NOT EXISTS (SELECT 'TRUE'
                 FROM dbo.[Database]
                WHERE ServerSQLID = @ServerID AND
                      DatabaseName = @DatabaseName)
   BEGIN
   INSERT dbo.[Database](
          ServerSQLID
        , DatabaseName
        , db_id
        , [Owner]
        , [DataSpaceUsage]
        , [IndexSpaceUsage]
        , [DatabaseSize]
        , [SpaceAvailable]
        , [PrimaryFilePath]
        , [IsFullTextEnabled]
        , Collation
        , RecoveryModel
        , CompatibilityLevel
        , [EncryptionEnabled]
        , [PageVerify]
        , [DatabaseOwnershipChaining]
        , [AutoClose]
        , [AutoCreateStatisticsEnabled]
        , [AutoShrink]
        , [AutoUpdateStatisticsAsync]
        , [AutoUpdateStatisticsEnabled]
        , LastBackup
        , LastDifferentialBackup
        , LastLogBackup
        , DBCreateDate
        , CreateDate
        , UpdateDate
        , Active)
   VALUES (
          @ServerID
        , @DatabaseName
        , @DatabaseID
        , @Owner
        , @DataSpaceUsage
        , @IndexSpaceUsage
        , @DatabaseSize
        , @SpaceAvailable
        , @PrimaryFilePath
        , @IsFullTextEnabled
        , @Collation
        , @RecoveryModel
        , @CompatibilityLevel
        , @EncryptionEnabled
        , @PageVerify
        , @DatabaseOwnershipChaining
        , @AutoClose
        , @AutoCreateStatisticsEnabled
        , @AutoShrink
        , @AutoUpdateStatisticsAsync
        , @AutoUpdateStatisticsEnabled
        , @LastBackup
        , @LastDifferentialBackup
        , @LastLogBackup
        , @DBCreateDate
        , GETDATE()
        , GETDATE()
        , @Active)
END
ELSE
   BEGIN
   IF EXISTS (SELECT 'TRUE'
                FROM dbo.[Database]
               WHERE ServerSQLID = @ServerID AND
                     DatabaseName = @DatabaseName AND
                     ([Owner] != @Owner OR
                       Collation != @Collation OR
                       CompatibilityLevel != @CompatibilityLevel OR
                       Lastbackup != @LastBackup OR
                       LastDifferentialBackup != @LastDifferentialBackup OR
                       LastLogBackup != @LastLogBackup OR
                       DBCreateDate != @DBCreateDate OR
                       RecoveryModel != @RecoveryModel))
      BEGIN 
      UPDATE dbo.[Database]
         SET [Owner] = @Owner
           , Collation = @Collation
           , RecoveryModel = @RecoveryModel
           , CompatibilityLevel = @CompatibilityLevel
           , Lastbackup = @LastBackup
           , LastDifferentialBackup = @LastDifferentialBackup
           , LastLogBackup = @LastLogBackup
           , DBCreateDate = @DBCreateDate
           , UpdateDate = GETDATE()
       WHERE ServerSQLID = @ServerID AND
             DatabaseName = @DatabaseName
   END
   ELSE
      BEGIN
      RETURN
   END
END

SET @ERRORCODE = @@ERROR

IF @ERRORCODE <> 0 
   BEGIN
   SET @ERRMSG = 'Upsert failed - ' + OBJECT_NAME(@@PROCID)
   SET @ERRMSG = @ERRMSG + ' Error Code: ' + RTRIM(CONVERT(CHAR, @ERRORCODE)) 
   RAISERROR (@ERRMSG, 16, 1)
   RETURN (-1)
END
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inserts or updates a record in the Database table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'pIU_Database'
GO
