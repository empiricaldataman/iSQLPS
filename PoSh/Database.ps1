param ( 
	[string]$instanceName = {},	# Name of the SQL Server instance to add into inventory. For a default instance, it is MSSQLSERVER.
	[string]$hostName = {}		# Name of the SQL Server host. 	
    )
    
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

function ConvertBoolToBit([Boolean] $expr){
	if ($expr) { return "1" }
	else { return "0" }
}

function Get-MinDate([datetime] $expr){
    if ($expr -eq '01/01/0001 00:00:00') {
        return '01/01/1900 00:00:00'
    }
}

#$strQuerySql = @"
#SELECT CASE WHEN s.InstanceName != 'MSSQLSERVER' THEN h.hostName +'\'+ s.InstanceName
#            ELSE h.HostName END as SQLNetworkName,
#       h.HostName,            
#       s.ServerID, 
#       s.tcpPort
#  FROM dbo.[server] s
#  JOIN dbo.[host] h on h.hostID = s.hostID AND
#       s.Active = 1 AND
#       h.Active = 1 AND
#       h.HostName = 'REMSYOUNDM101'
#"@
$strQuerySql = @"
SELECT @@SERVERNAME SQLNetworkName,
       SERVERPROPERTY('ComputerNamePhysicalNetBIOS') HostName,            
       1001 ServerID, 
       1433 tcpPort
"@

if ($InstanceName -notmatch "MSSQLSERVER") { $hostName = "$hostName\$InstanceName"}

try {
    $sqlInstances = Invoke-Sqlcmd -Query $strQuerySql -ServerInstance $hostName -Database "master" #-ErrorAction SilentlyContinue
}
catch {
    Write-Host("An error occurred while retrieving the list of servers from the inventory database.")
}


# Loop through all the servers and get the user databases on each of them.
foreach ($sqlInstance in $sqlInstances) {
    $strUpsertSql = $null
    $sqlNetworkName = $sqlInstance.SQLNetworkName
    $sqlHostName = $sqlInstance.HostName
	$ServerID = $sqlInstance.ServerID
	#$sqlTcpPort = $sqlInstance.tcpPort

    #$sqlDatabases = Get-SqlDatabase -sqlserver $sqlNetworkName
    $server = New-Object "Microsoft.SqlServer.Management.SMO.Server" $hostName
    $sqlDatabases = $server.Databases
    
    foreach ($sqlDatabase in $sqlDatabases) {
        $DatabaseName = $sqlDatabase.Name
        $Collation = $sqlDatabase.Collation
        $CompatibilityLevel = $sqlDatabase.CompatibilityLevel
        $DBCreateDate = $sqlDatabase.CreateDate
        $RecoveryModel = $sqlDatabase.RecoveryModel
        $Owner = $sqlDatabase.Owner
        $LastBackup = $sqlDatabase.LastBackupDate
        $LastDifferentialBackup = $sqlDatabase.LastDifferentialBackupDate
        $LastLogBackup = $sqlDatabase.LastLogBackupDate
        $AutoClose = $sqlDatabase.AutoClose
        $AutoCreateStatisticsEnabled = $sqlDatabase.AutoCreateStatisticsEnabled
        $AutoShrink = $sqlDatabase.AutoShrink
        $AutoUpdateStatisticsAsync = $sqlDatabase.AutoUpdateStatisticsAsync
        $AutoUpdateStatisticsEnabled = $sqlDatabase.AutoCreateStatisticsEnabled
        $DataSpaceUsed = $sqlDatabase.DataSpaceUsage
        $EncryptionEnabled = $sqlDatabase.EncryptionEnabled
        $DB_ID = $sqlDatabase.id
        $IndexSpaceUsage = $sqlDatabase.IndexSpaceUsage
        $PageVerify = $sqlDatabase.PageVerify
        $DatabaseOwnershipChaining = $sqlDatabase.DatabaseOwnershipChaining
        $DatabaseSize = $sqlDatabase.Size
        $SpaceAvailable = $sqlDatabase.SpaceAvailable
        $PrimaryFilePath = $sqlDatabase.PrimaryFilePath
        $IsFullTextEnabled = $sqlDatabase.IsFullTextEnabled
              

        #if (Test-iDatabase "$sqlHostName" "$sqlNetworkName" "$d") {
        #    $strUpsertSql += "exec dbo.pIU_Database "+ $ServerID + ", '"+ $DatabaseName +"', "+ $DB_ID + ", '"+ $Owner +"', '"+ $Collation +"', '"+ $RecoveryModel +"', '"+ $CompatibilityLevel +"', '"+ $(Get-MinDate($LastBackup)) +"', '"+ $(Get-MinDate($LastDifferentialBackup)) +"', '"+ $(Get-MinDate($LastLogBackup)) +"', '"+ $DBCreateDate +"', "+ $DataSpaceUsed +", "+ $IndexSpaceUsage +", "+ $DatabaseSize +", "+ $SpaceAvailable +", '"+ $PrimaryFilePath +"', "+ $(ConvertBoolToBit($IsFullTextEnabled)) +", '"+ $PageVerify +"', "+ $(ConvertBoolToBit($DatabaseOwnershipChaining)) +", "+ $(ConvertBoolToBit($EncryptionEnabled)) +", "+ $(ConvertBoolToBit($AutoClose)) +", "+ $(ConvertBoolToBit($AutoCreateStatisticsEnabled)) +", "+ $(ConvertBoolToBit($AutoShrink)) +", "+ $(ConvertBoolToBit($AutoUpdateStatisticsAsync)) +", "+ $(ConvertBoolToBit($AutoUpdateStatisticsEnabled)) +";`n"
        #}
        #else {
            $strUpsertSql += "exec dbo.pIU_Database "+ $ServerID + ", '"+ $DatabaseName +"', "+ $DB_ID + ", '"+ $Owner +"', '"+ $Collation +"', '"+ $RecoveryModel +"', '"+ $CompatibilityLevel +"', '"+ $(Get-MinDate($LastBackup)) +"', '"+ $(Get-MinDate($LastDifferentialBackup)) +"', '"+ $(Get-MinDate($LastLogBackup)) +"', '"+ $DBCreateDate +"', "+ $DataSpaceUsed +", "+ $IndexSpaceUsage +", "+ $DatabaseSize +", "+ $SpaceAvailable +", '"+ $PrimaryFilePath +"', "+ $(ConvertBoolToBit($IsFullTextEnabled)) +", '"+ $PageVerify +"', "+ $(ConvertBoolToBit($DatabaseOwnershipChaining)) +", "+ $(ConvertBoolToBit($EncryptionEnabled)) +", "+ $(ConvertBoolToBit($AutoClose)) +", "+ $(ConvertBoolToBit($AutoCreateStatisticsEnabled)) +", "+ $(ConvertBoolToBit($AutoShrink)) +", "+ $(ConvertBoolToBit($AutoUpdateStatisticsAsync)) +", "+ $(ConvertBoolToBit($AutoUpdateStatisticsEnabled)) +", 0;`n"
        #}

	}

	if ($strUpsertSql.Length -gt 0) {
        try {
            #Invoke-Sqlcmd -Query $strUpsertSql -ServerInstance $iSQLPSServer -Database $iSQLPSDatabase
            $strUpsertSql
            $strUpsertSql = $null
        }
        catch {
            Write-Host("An error occurred while inserting database information in the inventory database.")
        }
	}
}

