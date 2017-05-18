<#	
	.NOTES
	===========================================================================
	Created on:		04-06-2017
	Last Edited:	05-16-2017
	Version:		1.4
	Created by:		Nathan Davis
	Organization:	Ingram Content Group
	Filename:		Disable-Netbios.ps1
	Changes: 		
	===========================================================================
	.SYNOPSIS
		Disable Netbios on a list of Windows computers.
	
	.DESCRIPTION
		Disable Netbios on a list of Windows computers.

	.PARAMETER 
        serverFile - A text file containing the names of the servers to be added. Default is servers.txt in the 
        folder where the script is located.
        outputDir - Directory to put the script logs. Default is the folder where the script is located.

	.INPUTS
		Text file with the name of the servers to have netbios diabled.

	.OUTPUTS
		netbios script results.csv - Contains results of succesful changes.
        netbios script exceptions.csv - Contains errors when attemtped changes are unsuccesful.
		
	.EXAMPLE
	.\Disable-Netbios.ps1
    .\Disable-Netbios -serverFile "C:\scripts\data\servers.txt"
#>

Param(

    [string]$outputDir=(Split-Path $MyInvocation.MyCommand.Path),
    [string]$serverFile= (Split-Path $MyInvocation.MyCommand.Path) + '\servers.txt'
)

$resutlsFile = $outputDir + "\netbios script results.csv"
$errorFile = $outputDir + "\netbios script exceptions.csv"


Invoke-Command -ComputerName (Get-Content $serverFile) -ErrorAction SilentlyContinue -ErrorVariable ProcessError -scriptblock {
#    Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions
    $results = set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 2 -PassThru
    $infoObjects = @()


    foreach($result in $results){
        $infoObject = New-Object PSObject
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "NetworkInterface" -value $result.PSChildName
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "NetbiosOptions" -value $result.NetbiosOptions
        $infoObjects += $infoObject 
    }

    $infoObjects
} | Select-Object -Property PSComputerName, NetworkInterface, NetbiosOptions | Export-Csv $resutlsFile -NoTypeInformation
if($error){
    $ProcessError | Select-Object -Property TargetObject, FullyQualifiedErrorId, ErrorDetails | Export-CSV $errorFile -NoTypeInformation
}