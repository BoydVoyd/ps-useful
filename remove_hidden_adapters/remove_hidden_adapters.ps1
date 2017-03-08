Set-Location C:\_Source\DeviceManagement

Import-Module .\DeviceManagement.psd1 -Verbose

# List Hidden Devices

Get-Device -ControlOptions DIGCF_ALLCLASSES | Sort-Object -Property Name | Where-Object {($_.IsPresent -eq $false) -and ($_.Name -like “Microsoft Hyper-V Network Adapter*”) } | ft Name, DriverVersion, DriverProvider, IsPresent, HasProblem, InstanceId -AutoSize

# Get Hidden Hyper-V Net Devices

$hiddenHypVNics = Get-Device -ControlOptions DIGCF_ALLCLASSES | Sort-Object -Property Name | Where-Object {($_.IsPresent -eq $false) -and ($_.Name -like “Microsoft Hyper-V Network Adapter*”) }

# Loop and remove with DevCon.exe

ForEach ($hiddenNic In $hiddenHypVNics) {

$deviceid = “@” + $hiddenNic.InstanceId

.\devcon.exe -r remove $deviceid

}