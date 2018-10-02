IF OBJECT_ID(N'dbo.pIU_DatabaseFile','P') IS NOT NULL
   DROP PROCEDURE pIU_DatabaseFile
GO

----------------------------------------------------------------------
--  PROCEDURE NAME: dbo.pIU_DatabaseFile    
--     DESCRIPTION: Inserts or updates a record in the DatabaseFile table
----------------------------------------------------------------------
--   REFERENCED BY: DatabaseFile.ps1
--    PROJECT NAME: iSQLPS
--       EXISTS IN: SERVERNAME(s).DataBaseName
----------------------------------------------------------------------
--  CHANGE HISTORY:
--  DATE        MODIFIED   DESCRIPTION   
----------------------------------------------------------------------
--  09.10.2010  SYoung     Initial creation
----------------------------------------------------------------------
CREATE PROCEDURE [dbo].[pIU_DatabaseFile]
       @ServerID int,
       @DatabaseName varchar(128),
       @FileName varchar(128),
       @FilePath varchar(256),
       @FileSize int,
       @UsedSpace int,
       @FileGrowth int,
       @FileGrowthType char(10),
       @FileMaxSize bigint,
       @Active tinyint = 1

AS

SET NOCOUNT ON

DECLARE @ERRORCODE int, 
        @ERRMSG varchar (128),
        @DatabaseID int

SELECT @DatabaseID = DatabaseID
  FROM dbo.[Database]
 WHERE ServerSQLID = @ServerID AND
       DatabaseName = @DatabaseName

IF @DatabaseID IS NULL
   RETURN
  
IF EXISTS (SELECT 'TRUE'
             FROM dbo.DatabaseFile
            WHERE DatabaseID = @DatabaseID AND
                  [FileName] = @FileName AND
                  FilePath = @FilePath AND
                  FileSize = @FileSize AND
                  UsedSpace = @UsedSpace AND
                  FileGrowth = @FileGrowth AND
                  FileGrowthType = @FileGrowthType AND
                  FileMaxSize = @FileMaxSize)
   BEGIN
   RETURN
END
ELSE IF EXISTS (SELECT 'TRUE'
                  FROM dbo.DatabaseFile
                 WHERE DatabaseID = @DatabaseID AND
                       [FileName] = @FileName)
   BEGIN
   UPDATE dbo.DatabaseFile
      SET FilePath = @FilePath,
          FileSize = @FileSize,
          UsedSpace = @UsedSpace,
          FileGrowth = @FileGrowth,
          FileGrowthType = @FileGrowthType,
          FileMaxSize = @FileMaxSize,
          UpdateDate = GETDATE(),
          Active = @Active
    WHERE DatabaseID = @DatabaseID AND
          [FileName] = @FileName
END  
ELSE  
BEGIN  
    INSERT dbo.DatabaseFile (
           DatabaseID  
         , [FileName]
         , FilePath
         , FileSize
         , UsedSpace
         , FileGrowth
         , FileGrowthType
         , FileMaxSize
         , CreateDate  
         , UpdateDate
         , Active)
    VALUES (@DatabaseID  
         , @FileName
         , @FilePath
         , @FileSize
         , @UsedSpace
         , @FileGrowth
         , @FileGrowthType
         , @FileMaxSize
         , GETDATE()  
         , GETDATE()  
         , @Active)  
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
