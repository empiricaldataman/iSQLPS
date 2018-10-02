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
    #$server.SetDefaultInitfields([Microsoft.SqlServer.Management.SMO.Database], "IsSystemObject")
    $sqlDatabases = $server.Databases    
    
	if ($sqlDatabases) {
		Foreach ($sqlDatabase in $sqlDatabases) {
            $fileGroups = $sqlDatabase.FileGroups
            $logFiles = $sqlDatabase.LogFiles
			
			Foreach ($fileGroup in $FileGroups) {
				$files = $fileGroup.Files
				Foreach ($file in $Files) {
					$strUpsertSql += "exec dbo.pIU_DatabaseFile " + $ServerID + ", '" + $sqlDatabase.name + "', '" + $file.Name + "', '" + $file.FileName + "', " + $file.Size + ", " + $file.UsedSpace + ", " + $file.Growth + ", '" + $file.GrowthType + "', " + $file.MaxSize + ";`n"
				}
			}

            Foreach ($logFile in $logFiles) {
                $strUpsertSql += "exec dbo.pIU_DatabaseFile " + $ServerID + ", '" + $sqlDatabase.name + "', '" + $logFile.Name + "', '" + $logFile.FileName + "', " + $logFile.Size + ", " + $logFile.UsedSpace + ", " + $logFile.Growth + ", '" + $logFile.GrowthType + "', " + $logFile.MaxSize + ";`n"
            }
        }
    }
    else {
    $strUpsertSql = ""
	}

	if ($strUpsertSql.Length -gt 0) {
        try {
            #Invoke-Sqlcmd -Query $strUpsertSql -ServerInstance $iSQLPSServer -Database $iSQLPSDatabase
            $strUpsertSql
        }
        catch {
            Write-Host("An error occurred while inserting database information in the inventory database.")
        }
    }
}
