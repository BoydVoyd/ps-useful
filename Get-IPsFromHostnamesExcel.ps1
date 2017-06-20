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

    [string]$hostFile= (Split-Path $MyInvocation.MyCommand.Path) + '\hosts.xlsx',
    [string]$outputDir=(Split-Path $hostFile)
)

$hostFileName = (Split-Path $hostFile -Leaf).split(".")[0]
$resutlsFile = $outputDir + "\" + $hostFileName + "_withIPs_$(get-date -f MM-dd-yyyy-HHmmss).xlsx"
$devices = Import-Excel $hostFile
foreach ($device in $devices)
{
    Write-Host $device.Name
    $addresses = $null
    try {
        $addresses = [System.Net.Dns]::GetHostAddresses($device.Name).IPAddressToString
    }
    catch { 
        Add-Member -inputObject $device -memberType NoteProperty -name "IP" -value "999.999.999.999"
    }
    foreach($address in $addresses) {
        Add-Member -inputObject $device -memberType NoteProperty -name "IP" -value $address
    }
}

$devices | Sort-Object { [system.version]$_.IP } | Export-Excel $resutlsFile