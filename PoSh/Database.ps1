
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

$a = Import-Csv -Path database_prd.txt -Delimiter ','

foreach ($i in $a) {
    $InstanceName = $i.InstanceName
    $hostName = $i.Host
    $ServerID = $i.ServerID
    
    if ($InstanceName -notmatch "MSSQLSERVER") { $hostName = "$hostName\$InstanceName"}

    $server = New-Object "Microsoft.SqlServer.Management.SMO.Server" $hostName
    $server.SetDefaultInitfields([Microsoft.SqlServer.Management.SMO.Database], "IsSystemObject")
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
              
        $strUpsertSql += "exec dbo.pIU_Database "+ $ServerID + ", '"+ $DatabaseName +"', "+ $DB_ID + ", '"+ $Owner +"', '"+ $Collation +"', '"+ $RecoveryModel +"', '"+ $CompatibilityLevel +"', '"+ $(Get-MinDate($LastBackup)) +"', '"+ $(Get-MinDate($LastDifferentialBackup)) +"', '"+ $(Get-MinDate($LastLogBackup)) +"', '"+ $DBCreateDate +"', "+ $DataSpaceUsed +", "+ $IndexSpaceUsage +", "+ $DatabaseSize +", "+ $SpaceAvailable +", '"+ $PrimaryFilePath +"', "+ $(ConvertBoolToBit($IsFullTextEnabled)) +", '"+ $PageVerify +"', "+ $(ConvertBoolToBit($DatabaseOwnershipChaining)) +", "+ $(ConvertBoolToBit($EncryptionEnabled)) +", "+ $(ConvertBoolToBit($AutoClose)) +", "+ $(ConvertBoolToBit($AutoCreateStatisticsEnabled)) +", "+ $(ConvertBoolToBit($AutoShrink)) +", "+ $(ConvertBoolToBit($AutoUpdateStatisticsAsync)) +", "+ $(ConvertBoolToBit($AutoUpdateStatisticsEnabled)) +", 0;`n"
	}

	if ($strUpsertSql.Length -gt 0) {
        try {
            $strUpsertSql
            $strUpsertSql = $null
        }
        catch {
            Write-Host("An error occurred while inserting database information in the inventory database.")
        }
	}
}

