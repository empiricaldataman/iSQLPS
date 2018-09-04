IF OBJECT_ID(N'dbo.pIU_Server','P') IS NOT NULL
   DROP PROCEDURE dbo.pIU_Server
GO

CREATE PROCEDURE [dbo].[pIU_Server]
       @instanceName [varchar] (128)
     , @hostName [varchar] (128)
     , @ComputerNamePhysicalNetBIOS [varchar](128)
     , @DomainInstanceName [varchar](128)
     , @ClusterName [varchar](128)
     , @IsClustered [bit]
     , @Environment [char](1) 
     , @Edition [varchar](128) 
     , @Version [varchar](25) 
     , @Product [varchar](128)
     , @ProductLevel [varchar](12) 
     , @Platform [varchar](128) 
     , @Collation [varchar](128) 
     , @tcpEnabled [bit] 
     , @tcpName [varchar](128) 
     , @tcpPort [varchar](15) 
     , @NamePipesEnabled [bit] 
     , @NamePipesName [varchar](128) 	
     , @DefaultFile [varchar](256) 
     , @DefaultLog [varchar](256) 
     , @ErrorLogPath [varchar](256) 
     , @MasterDbLogPath [varchar](256) 
     , @MasterDbPath [varchar](256) 
     , @BackupDirectory [varchar](256) 
     , @ServiceAccount [varchar](128) 
     , @ServiceStartMode [varchar](128) 
     , @BrowserServiceAccount [varchar](128) 
     , @BrowserStartMode [varchar](128) 
     , @LoginMode [varchar](128) 
     , @NumberOfLogFiles [varchar](128) 
     , @ResourceLastUpdateDate [smalldatetime]
     , @Active bit

AS

DECLARE @ERRORCODE [int], @ERRMSG [varchar] (128)
DECLARE @hostID [int], @clusterID [int]

-- If the server resides on a standalone host
IF (@hostName is NOT Null)
BEGIN
	-- Verify the host name
	SELECT @hostID = hostID FROM [dbo].[Host] WHERE hostName=@hostName

	IF (@hostID > 0) 
		BEGIN
		-- If the server does not exist in the inventory, perform an insertion. 
		IF NOT EXISTS (SELECT ServerID 
                         FROM dbo.[Server]
				        WHERE instanceName = @instanceName
                          AND HostID = @hostID)
   			INSERT INTO [dbo].[Server](
                   [HostID]
                 , [InstanceName]
                 , [ComputerNamePhysicalNetBIOS]
                 , [DomainInstanceName]
                 , [ClusterName]
                 , [IsClustered]
                 , [Environment]
                 , [Edition]
                 , [Version]
                 , [Product]
                 , [ProductLevel]
                 , [Platform]
                 , [Collation]
                 , [tcpEnabled]
                 , [tcpName]
                 , [tcpPort]
                 , [NamePipesEnabled]
                 , [NamePipesName]
                 , [DefaultFile]
                 , [DefaultLog]
                 , [ErrorLogPath]
                 , [MasterDbLogPath]
                 , [MasterDbPath]
                 , [BackupDirectory]
                 , [ServiceAccount]
                 , [ServiceStartMode]
                 , [BrowserServiceAccount]
                 , [BrowserStartMode]
                 , [LoginMode]
                 , [NumberOfLogFiles]
                 , [ResourceLastUpdateDate]
                 , [CreateDate]
                 , [UpdateDate]
                 , [Active])
   			VALUES (@HostID
                 , @InstanceName
                 , @ComputerNamePhysicalNetBIOS
                 , @DomainInstanceName
                 , @ClusterName
                 , @IsClustered
                 , @Environment
                 , @Edition
                 , @Version
                 , @Product
                 , @ProductLevel 
                 , @Platform
                 , @Collation
                 , @tcpEnabled
                 , @tcpName
                 , @tcpPort
                 , @NamePipesEnabled
                 , @NamePipesName	
                 , @DefaultFile
                 , @DefaultLog
                 , @ErrorLogPath
                 , @MasterDbLogPath
                 , @MasterDbPath
                 , @BackupDirectory
                 , @ServiceAccount
                 , @ServiceStartMode
                 , @BrowserServiceAccount
                 , @BrowserStartMode
                 , @LoginMode
                 , @NumberOfLogFiles
                 , @ResourceLastUpdateDate
				 , GETDATE()
				 , GETDATE()
                 , @Active)
		-- If the server already exists in the inventory, perform an update. 
		ELSE
			UPDATE [dbo].[Server]
			   SET [ComputerNamePhysicalNetBIOS] = @ComputerNamePhysicalNetBIOS
                 , [DomainInstanceName] = @DomainInstanceName
                 , [ClusterName] = @ClusterName
                 , [IsClustered] = @IsClustered
                 , [Environment] = @Environment
                 , [Edition] = @Edition
                 , [Version] = @Version
                 , [Product] = @Product
                 , [ProductLevel] = @ProductLevel
                 , [Platform] = @Platform
                 , [Collation] = @Collation
                 , [tcpEnabled] = @tcpEnabled
                 , [tcpName] = @tcpName
                 , [tcpPort] = @tcpPort
                 , [NamePipesEnabled] = @NamePipesEnabled
                 , [NamePipesName] = @NamePipesName
                 , [DefaultFile] = @DefaultFile
                 , [DefaultLog] = @DefaultLog
                 , [ErrorLogPath] = @ErrorLogPath
                 , [MasterDbLogPath] = @MasterDbLogPath
                 , [MasterDbPath] = @MasterDbPath
                 , [BackupDirectory] = @BackupDirectory
                 , [ServiceAccount] = @ServiceAccount
                 , [ServiceStartMode] = @ServiceStartMode
                 , [BrowserServiceAccount] = @BrowserServiceAccount
                 , [BrowserStartMode] = @BrowserStartMode
                 , [LoginMode] = @LoginMode
                 , [NumberOfLogFiles] = @NumberOfLogFiles
                 , [ResourceLastUpdateDate] = @ResourceLastUpdateDate
			     , [UpdateDate] = GETDATE()
             WHERE InstanceName = @instanceName
               AND HostID = @hostID
		END
	-- If the host name is invalid, raise an error and exit.
	ELSE
		BEGIN
			SET @ERRMSG = 'Upsert failed - ' + OBJECT_NAME(@@PROCID)
			SET @ERRMSG = @ERRMSG + ' Host ' + @hostName + ' does not exist. Please add the host first.' 
			RAISERROR (@ERRMSG, 16, 1)
			RETURN (-1)
        END
END
-- If the server resides on a cluster
ELSE 
BEGIN   	
	-- Verify the cluster name
	SELECT @clusterID = ClusterID 
      FROM [dbo].[Cluster] 
     WHERE SQLClusterName = @clusterName
	IF (@clusterID > 0)
       BEGIN
-- If the server does not exist in the inventory, perform an insertion. 
       IF NOT EXISTS (SELECT ServerID 
                        FROM dbo.[Server]
		               WHERE InstanceName = @instanceName
                         AND ClusterID = @clusterID)
       INSERT INTO [dbo].[Server](
              InstanceName
            , HostID
            , ClusterID
            , [ComputerNamePhysicalNetBIOS]
            , [DomainInstanceName]
            , [ClusterName]
            , [IsClustered]
            , [Environment]
            , [Edition]
            , [Version]
            , [Product]
            , [ProductLevel]
            , [Platform]
            , [Collation]
            , [tcpEnabled]
            , [tcpName]
            , [tcpPort]
            , [NamePipesEnabled]
            , [NamePipesName]
            , [DefaultFile]
            , [DefaultLog]
            , [ErrorLogPath]
            , [MasterDbLogPath]
            , [MasterDbPath]
            , [BackupDirectory]
            , [ServiceAccount]
            , [ServiceStartMode]
            , [BrowserServiceAccount]
            , [BrowserStartMode]
            , [LoginMode]
            , [NumberOfLogFiles]
            , [ResourceLastUpdateDate]
            , [CreateDate]
            , [UpdateDate]
            , [Active])
       VALUES (@InstanceName
            , NULL
            , @ClusterID 
            , @ComputerNamePhysicalNetBIOS
            , @DomainInstanceName
            , @ClusterName
            , @IsClustered
            , @Environment
            , @Edition
            , @Version
            , @Product
            , @ProductLevel 
            , @Platform
            , @Collation
            , @tcpEnabled
            , @tcpName
            , @tcpPort
            , @NamePipesEnabled
            , @NamePipesName	
            , @DefaultFile
            , @DefaultLog
            , @ErrorLogPath
            , @MasterDbLogPath
            , @MasterDbPath
            , @BackupDirectory
            , @ServiceAccount
            , @ServiceStartMode
            , @BrowserServiceAccount
            , @BrowserStartMode
            , @LoginMode
            , @NumberOfLogFiles
            , @ResourceLastUpdateDate
            , GETDATE()
            , GETDATE()
            , @Active)
		-- If the server already exists in the inventory, perform an update. 
		ELSE
			UPDATE [dbo].[Server]
			   SET [InstanceName] = @instanceName
                 , [HostID] = NULL
                 , [ClusterID] = @clusterID
                 , [ComputerNamePhysicalNetBIOS] = @ComputerNamePhysicalNetBIOS
                 , [DomainInstanceName] = @DomainInstanceName
                 , [ClusterName] = @ClusterName
                 , [IsClustered] = @IsClustered
                 , [Environment] = @Environment
                 , [Edition] = @Edition
                 , [Version] = @Version
                 , [Product] = @Product
                 , [ProductLevel] = @ProductLevel
                 , [Platform] = @Platform
                 , [Collation] = @Collation
                 , [tcpEnabled] = @tcpEnabled
                 , [tcpName] = @tcpName
                 , [tcpPort] = @tcpPort
                 , [NamePipesEnabled] = @NamePipesEnabled
                 , [NamePipesName] = @NamePipesName
                 , [DefaultFile] = @DefaultFile
                 , [DefaultLog] = @DefaultLog
                 , [ErrorLogPath] = @ErrorLogPath
                 , [MasterDbLogPath] = @MasterDbLogPath
                 , [MasterDbPath] = @MasterDbPath
                 , [BackupDirectory] = @BackupDirectory
                 , [ServiceAccount] = @ServiceAccount
                 , [ServiceStartMode] = @ServiceStartMode
                 , [BrowserServiceAccount] = @BrowserServiceAccount
                 , [BrowserStartMode] = @BrowserStartMode
                 , [LoginMode] = @LoginMode
                 , [NumberOfLogFiles] = @NumberOfLogFiles
                 , [ResourceLastUpdateDate] = @ResourceLastUpdateDate
                 , [UpdateDate] = GETDATE()
             WHERE InstanceName = @instanceName
               AND ClusterID = @clusterID
		END
	-- If the cluster name is invalid, raise an error and exit.
	ELSE
		BEGIN
			SET @ERRMSG = 'Upsert failed - ' + OBJECT_NAME(@@PROCID)
			SET @ERRMSG = @ERRMSG + ' Cluster ' + @clusterName + ' does not exist. Please add the cluster first.' 
			RAISERROR (@ERRMSG, 16, 1)
			RETURN (-1)
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
