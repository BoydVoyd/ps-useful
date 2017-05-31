<#	
	.NOTES
	===========================================================================
	Created on:		05-30-2017
	Last Edited:	05-30-2017
	Version:		1.0
	Created by:		Nathan Davis
	Organization:	Ingram Content Group
	Filename:		Get-IPsFromHostnames.ps1
	Changes: 		
	===========================================================================
	.SYNOPSIS
		Get IP addresses for a list of hostnames.
	
	.DESCRIPTION
		Get IP addresses for a list of hostnames.

	.PARAMETERS
    hostFile - A text file containing a list of hostnames. Default is hosts.txt in the 
    folder where the script is located.
    outputDir - Directory to put the script output. Default is the folder where $hostFile is located.

	.INPUTS
		Text file with the list of hosts to be looked up.

	.OUTPUTS
		ip_lookup_results_(datetime).csv - Contains results of IP address lookups.
		
	.EXAMPLE
  .\Get-IPsFromHostnames.ps1 -hostFile "C:\scripts\data\hosts.txt"
#>

Param(

    [string]$hostFile= (Split-Path $MyInvocation.MyCommand.Path) + '\hosts.txt',
    [string]$outputDir=(Split-Path $hostFile)
)

$resutlsFile = $outputDir + "\ip_lookup_results_$(get-date -f dd-MM-yyyy-HHmmss).csv"
$devices = get-content $hostFile
$infoObjects = @()
foreach ($device in $devices)
{
    $addresses = $null
    try {
        $addresses = [System.Net.Dns]::GetHostAddresses("$device").IPAddressToString
    }
    catch { 
        $infoObject = New-Object PSObject
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "DeviceName" -value $device
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "IP" -value "IP Not Found"
        $infoObjects += $infoObject 
    }
    foreach($address in $addresses) {
        $infoObject = New-Object PSObject
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "DeviceName" -value $device
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "IP" -value $address
        $infoObjects += $infoObject 
    }
}

$infoObjects #| Sort-Object IP | Export-Csv $resutlsFile -NoTypeInformation