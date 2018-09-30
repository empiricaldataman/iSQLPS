USE [DPR]
GO

IF OBJECT_ID(N'dbo.pIU_Configuration','P') IS NOT NULL
   DROP PROCEDURE pIU_Configuration
GO

------------------------------------------------------------------------------------
--  PROCEDURE NAME: dbo.pIU_Configuration    
--     DESCRIPTION: Inserts or updates a record in the Configuration table
------------------------------------------------------------------------------------
--   REFERENCED BY: Configuration.ps1
--    PROJECT NAME: iSQLPS
------------------------------------------------------------------------------------
--  CHANGE HISTORY:
-- DATE        MODIFIED   DESCRIPTION   
------------------------------------------------------------------------------------
-- 09.30.2018  SYoung     Initial creation
------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[pIU_Configuration]
       @instanceName [varchar] (128)
     , @hostName [varchar] (128)
     , @ConfigurationID int
     , @DisplayName varchar(128)
     , @Description varchar(128)
     , @RunValue int
              
AS

SET NOCOUNT ON

DECLARE @ERRORCODE int, 
        @ERRMSG varchar(128)

IF NOT EXISTS (SELECT 'TRUE'
                 FROM dbo.[Configuration]
                WHERE InstanceName = @instanceName AND
                      HostName = @hostName)
   BEGIN
   INSERT dbo.[Configuration](
          InstanceName
        , HostName
        , ConfigurationID
        , DisplayName
        , [Description]]
        , RunValue
        , DBCreateDate
        , CreateDate
        , UpdateDate)
   VALUES (
          @instanceName
        , @hostName
        , @ConfigurationID
        , @DisplayName
        , @Description
        , @RunValue
        , @DBCreateDate
        , GETDATE()
        , GETDATE()
        , @Active)
END
ELSE
   BEGIN
   IF EXISTS (SELECT 'TRUE'
                FROM dbo.[Configuration]
               WHERE InstanceName = @instanceName AND
                     HostName = @HostName AND
                     ConfigurationID = @ConfigurationID AND
                     RunValue != @RunValue)
      BEGIN 
      UPDATE dbo.[Configuration]
         SET RunValue = @RunValue
           , UpdateDate = GETDATE()
       WHERE InstanceName = @instanceName AND
             HostName = @hostName
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


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inserts or updates a record in the Configuration table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'pIU_Configuration'
GO
