IF OBJECT_ID(N'dbo.pIU_Host','P') IS NOT NULL
   DROP PROCEDURE dbo.pIU_Host
GO

CREATE PROCEDURE [dbo].[pIU_Host]			
       @hostName [varchar] (128)
     , @location [char] (2)
     , @description [varchar] (500)
     , @primaryBU [varchar] (128)
     , @timeZone [varchar] (128)
     , @enableDaylightSavingsTime [bit]
     , @domain [varchar] (128)
     , @manufacturer [varchar] (128)
     , @model [varchar] (128)
     , @systemType [varchar] (128)
     , @systemStartupOptions [varchar] (128)
     , @numberOfProcessors [tinyint]
     , @numberOfLogicalProcessors [tinyint]
     , @numberOfCores [tinyint]
     , @processorType [varchar] (128)
     , @totalPhysicalMemory [bigint]
     , @countryCode [varchar] (128)
     , @lastBootUpTime [smalldatetime]
     , @locale [varchar] (128)
     , @OS [varchar] (128)
     , @version [varchar] (128)
     , @servicePackMajorVersion [varchar] (10)
     , @servicePackMinorVersion [varchar] (10)
     , @buildNumber [varchar] (20)
     , @installDate [smalldatetime]
     , @totalVisibleMemorySize [bigint]
     , @totalVirtualMemorySize [bigint]
     , @pagingFileSize [bigint]
     , @IP1 [varchar] (128)
     , @IP2 [varchar] (128)
     , @IP3 [varchar] (128)
     , @IP4 [varchar] (128)
     , @IP5 [varchar] (128)
     , @IP6 [varchar] (128)
     , @active bit

AS

DECLARE @ERRORCODE [int], @ERRMSG [varchar] (128)

-- If the host doesn't exist in the Hosts table, then perform an insertion.
IF NOT EXISTS (SELECT hostID FROM dbo.Host WHERE hostName=@hostName)
   INSERT [dbo].[Host] (
          hostName
        , [location]
        , [description]
        , primaryBU
        , timeZone
        , enableDaylightSavingsTime
        , domain
        , manufacturer
        , model
        , systemType
        , systemStartupOptions
        , numberOfProcessors
        , numberOfLogicalProcessors
        , numberOfCores
        , ProcessorType
        , totalPhysicalMemory
        , countryCode
        , lastBootUpTime
        , locale
        , OS
        , [version]
        , servicePackMajorVersion
        , servicePackMinorVersion
        , buildNumber
        , installDate
        , totalVisibleMemorySize
        , totalVirtualMemorySize
        , pagingFileSize
        , IP1
        , IP2
        , IP3
        , IP4
        , IP5
        , IP6
        , createDate
        , updateDate
        , active)
   VALUES(@hostName
        , @location
        , @description
        , @primaryBU
        , @timeZone
        , @enableDaylightSavingsTime
        , @domain
        , @manufacturer
        , @model
        , @systemType
        , @systemStartupOptions
        , @numberOfProcessors
        , @numberOfLogicalProcessors
        , @numberOfCores
        , @processorType
        , @totalPhysicalMemory
        , @countryCode
        , @lastBootUpTime
        , @locale
        , LTRIM(RTRIM(LEFT(@OS,CHARINDEX('|',@OS) - 1)))
        , @version
        , @servicePackMajorVersion
        , @servicePackMinorVersion
        , @buildNumber
        , @installDate
        , @totalVisibleMemorySize
        , @totalVirtualMemorySize
        , @pagingFileSize
        , @IP1
        , @IP2
        , @IP3
        , @IP4
        , @IP5
        , @IP6
        , GETDATE()
        , GETDATE()
        , @active)
-- If the host already exists in the Hosts table, then perform an update.
ELSE
	UPDATE [dbo].[Host]
   	   SET [location] = @location
         , [description] = @description
         , [primaryBU] = @primaryBU
         , [timeZone] = @timeZone
         , [enableDaylightSavingsTime] = @enableDaylightSavingsTime
         , [domain] = @domain
         , [manufacturer] = @manufacturer
         , [model] = @model
         , [systemType] = @systemType
         , [systemStartupOptions] = @systemStartupOptions 
         , [numberOfProcessors] = @numberOfProcessors
         , [numberOfLogicalProcessors] = @numberOfLogicalProcessors
         , [numberOfCores] = @numberOfCores
         , [processorType] = @processorType
         , [totalPhysicalMemory] = @totalPhysicalMemory
         , [countryCode] = @countryCode
         , [lastBootUpTime] = @lastBootUpTime
         , [locale] = @locale
         , [OS] = LTRIM(RTRIM(LEFT(@OS,CHARINDEX('|',@OS) - 1)))
         , [version] = @version
         , [servicePackMajorVersion] = @servicePackMajorVersion
         , [servicePackMinorVersion] = @servicePackMinorVersion
         , [buildNumber] = @buildNumber
         , [installDate] = @installDate
         , [totalVisibleMemorySize] = @totalVisibleMemorySize
         , [totalVirtualMemorySize] = @totalVirtualMemorySize
         , [pagingFileSize] = @pagingFileSize
         , [IP1] = @IP1
         , [IP2] = @IP2 
         , [IP3] = @IP3 
         , [IP4] = @IP4 
         , [IP5] = @IP5 
         , [IP6] = @IP6 
         , [updateDate] = GETDATE()
	 WHERE hostName=@hostName
	

SET @ERRORCODE = @@ERROR
   IF @ERRORCODE <> 0 
      BEGIN
          SET @ERRMSG = 'Insert failed - ' + OBJECT_NAME(@@PROCID)
          SET @ERRMSG = @ERRMSG + ' Error Code: ' + RTRIM(CONVERT(CHAR, @ERRORCODE)) 
          RAISERROR (@ERRMSG, 16, 1)
          RETURN (-1)
      END
   ELSE
	RETURN (0)
GO
