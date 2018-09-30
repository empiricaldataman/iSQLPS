<#-----------------------------------------------------------------------------------------------
        NAME: Configuration.ps1
       EMAIL: saleyoun@hotmail.com
 DESCRIPTION: This script adds a ServerSQL record into inventory. If the record
              already exists, then this script updates the existing ServerSQL record.
              
     EXAMPLE: Configuration -InstanceName "MSSQLSERVER" -ServerName "POWERPC"
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			  killing your buzz or ANYTHING else that can be thought up.
-----------------------------------------------------------------------------------------------#>
param ( 
	[switch]$help,
	[string]$instanceName = {},	# Name of the SQL Server instance to add into inventory. For a default instance, it is MSSQLSERVER.
	[string]$hostName = {},		# Name of the SQL Server host. 	
	[string]$clusterName = {},	# Name of the SQL Server cluster.
	[string]$environment = {}	# environment of the SQL Server instance. Possible values include D, Q, P, U and R.
    )

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

if ($hostName.Length -gt 0) {
	$sqlNetworkName = $hostName
	$windowsNetworkName = $hostName
}

if ($InstanceName -notmatch "MSSQLSERVER") { $hostName = "$hostName\$InstanceName"}

[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")|out-null
$oServer = New-Object "Microsoft.SqlServer.Management.Smo.Server" "$hostName"
$oProperties = $oServer.Configuration.Properties

foreach ($oProperty in $oProperties) {
$strUpsertSql += "EXEC dbo.pIU_Configuration '$instanceName', '$hostName', '" + $oProperty.Number + "', '"+ $oProperty.DisplayName +"', '"+ $oProperty.Description +"', '"+ $oProperty.ConfigValue +"';`n"
}

$strUpsertSql
#Invoke-Sqlcmd -Query $strUpsertSql -ServerInstance $iSQLPSServer -Database $iSQLPSDatabase