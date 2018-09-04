<#------------------------------------------------------------------------------------------------
        NAME: Host.ps1
  CREATED ON: 09.03.2012
      AUTHOR: Sal Young
 MODIFIED BY: 
       EMAIL: saleyoun@homail.com
 DESCRIPTION: This script inserts a SQL Server host record into inventory. If the host already
              exists, then this script updates the existing host record.
              
     EXAMPLE: Upsert-Host.ps1 -host POWERPC -region NA -location CH -primaryBU STP -description 'For STP application testing'
-------------------------------------------------------------------------------------------------
  DISCLAIMER: The AUTHOR  ASSUMES NO RESPONSIBILITY  FOR ANYTHING, including  the destruction of 
              personal property, creating singularities, making deep fried chicken, causing your 
              toilet to  explode, making  your animals spin  around like mad, causing hair loss, 
			  killing your buzz or ANYTHING else that can be thought up.
-------------------------------------------------------------------------------------------------#>
param ( 
	[switch]$help,
	[string]$hostName = {},	    # Name of the host to add into inventory.
	[string]$location = {},		# Code of the city in which the SQL host locates. For example, NY for New York, CH for Chicago.
	[string]$primaryBU = {},	# Primary BU that owns this host
	[string]$description = {}	# Brief description of the host. For example, which application/project the host supports.
    )

function ConvertBoolToBit([Boolean] $expr){
	if ($expr) { return "1" }
	else { return "0" }
}


function ConvertOSTime([String] $osTime){
	return $osTime.SUBSTRING(0, 4) + "-" + $osTime.SUBSTRING(4, 2) + '-' + $osTime.SUBSTRING(6, 2) + ' ' + $osTime.SUBSTRING(8, 2) + ':' + $osTime.SUBSTRING(10, 2)
}



# Main Program 
[String] $strUpsertSql=""

if ( $help ) {
	"Usage: UpSert-Host -host <string[]> -region <string[]> -location <string[]> -primaryBU <string[]> [-description <string[]>]"
	exit 0
}

if ( $hostName.Length -eq 0 ) {
	"Please enter a host name."
        exit 1
}

if ( $location -notmatch '^\w{2}$' ) {
        "The location is invalid. Please enter a 2-character city code."
        exit 1
}

if ( $primaryBU.Length -eq 0 ) {
	"Please enter a primary BU."
        exit 1
}

# Construct the insert statement
$strUpsertSql = $strUpsertSql + "exec dbo.pIU_Host '$hostName', '$location', '$description', '$primaryBU', "

# Get the time zone
$reg = [WMIClass]"\\$hostName\root\default:stdRegProv"
$HKEY_LOCAL_MACHINE = 2147483650
$strKeyPath = "SYSTEM\CurrentControlSet\Control\TimeZoneInformation"

if ($reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TimeZoneKeyName").svalue) {
	$strUpsertSql = $strUpsertSql + "'" + $reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"TimeZoneKeyName").svalue  + "', "
}
else {
	$strUpsertSql = $strUpsertSql + "'" + $reg.GetStringValue($HKEY_LOCAL_MACHINE,$strKeyPath,"StandardName").svalue  + "', "
}
 
$cs = Get-WMIObject -computerName $hostName -Class Win32_ComputerSystem
$pr = Get-WmiObject -ComputerName $hostName -Class Win32_Processor

# Get the setting of the daylight savings time
# This property is only available for Windows XP or later
if ($cs.EnableDaylightSavingsTime) { 
	$enableDST=(ConvertBoolToBit $cs.EnableDaylightSavingsTime)
}
else {
	$strKeyPath = "SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
	switch ($reg.GetDWORDValue($HKEY_LOCAL_MACHINE,$strKeyPath,"DisableAutoDaylightTimeSet").uValue) {
	1 	{$enableDST="0"}
	default	{$enableDST="1"}
	}
}

# Get the number of logical processors
# This property is only available for Windows XP or later
if ($cs.NumberOfLogicalProcessors) { 
	$numLogicalProcessors=$cs.NumberOfLogicalProcessors
}
else {
	$numLogicalProcessors=$cs.NumberOfProcessors
}

$strUpsertSql = $strUpsertSql + $enableDST + ", '" + $cs.Domain + "', '" `
                + $cs.Manufacturer.Trim() + "', '" + $cs.Model.Trim() + "', '" + $cs.SystemType + "', '" `
                + $cs.SystemStartupOptions + "', " + $cs.NumberOfProcessors + ", " `
				+ $numLogicalProcessors + ", " + $pr.NumberOfCores + ", '" `
				+ $pr.Name +"', "+ $cs.TotalPhysicalMemory +", " 

# Get the Operating System information, such as country code, last bootup time, etc.
$os = Get-WMIObject -computerName $hostName -class Win32_OperatingSystem

$strUpsertSql = $strUpsertSql + "'" + $os.CountryCode + "', '" + (ConvertOSTime $os.LastBootUpTime) + "', '" + $os.Locale + "', '" `
                + $os.Name + "', '" + $os.Version + "', '" + $os.ServicePackMajorVersion + "', '" `
                + $os.ServicePackMinorVersion + "', '" + $os.BuildNumber + "', '" + (ConvertOSTime $os.InstallDate) + "', " `
                + $os.TotalVisibleMemorySize + ", " `
                + $os.TotalVirtualMemorySize + ", " + $os.SizeStoredInPagingFiles

# Get the IP address information.
$IPArr = ( get-wmiobject -computername $hostName -class "Win32_NetworkAdapterConfiguration" | where {$_.IpEnabled -match "True" } )

if ($IPArr.Length) {
	for ($i = 0; $i -lt 6; $i++) {

		if ($i -lt $IPArr.Length) {
			$strUpsertSql = $strUpsertSql + ", '" + $IPArr[$i].IPAddress[0] + "'"
		}
		else {
			$strUpsertSql = $strUpsertSql + ", ''"
		}
	}
}
else {
	$strUpsertSql = $strUpsertSql + ", '" + $IPArr.IPAddress[0] + "', '', '', '', '', ''"
}
		
$strUpsertSql=$strUpsertSql + ", 1;"
$strUpsertSql

#Invoke-Sqlcmd -Query $strUpsertSql -ServerInstance $inventoryServer -Database $inventoryDatabase
