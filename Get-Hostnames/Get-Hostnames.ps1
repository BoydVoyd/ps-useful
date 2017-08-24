<#	
	.NOTES
	===========================================================================
	Created on:		07-26-2017
	Last Edited:	07-26-2017
	Version:		1.0
	Created by:		Nathan Davis
	Organization:	Ingram Content Group
	Filename:		Get-Hostnames.ps1
	Changes: 		
	===========================================================================
	.SYNOPSIS
		Get the hostname from a list of computers.
	
	.DESCRIPTION
		Trying to find computers that are no longer on the network.

	.PARAMETER 
        wsFile - A text file containing the names workstations to be polled. Default is workstations.txt in the 
        folder where the script is located.
        outputDir - Directory to put the script logs. Default is the folder where the script is located.

	.INPUTS
		Text file with the name of the servers to have netbios diabled.

	.OUTPUTS
		hostname results.txt- Contains results of workstations with the same name.
        \hostname script exceptions.csv - Contains errors when polling fails
		
	.EXAMPLE
	.\Get-Hostnames.ps1
    .\Get-Hostnames.ps1 -wsFile "C:\scripts\data\workstations.txt"
#>

Param(

    [string]$outputDir=(Split-Path $MyInvocation.MyCommand.Path),
    [string]$wsFile= (Split-Path $MyInvocation.MyCommand.Path) + '\workstations.txt'
)

$resutlsFile = $outputDir + "\hostname results.txt"
$errorFile = $outputDir + "\hostname script exceptions.csv"



Invoke-Command -ComputerName (Get-Content $wsFile) -ErrorAction SilentlyContinue -ErrorVariable ProcessError -scriptblock {
    $env:computername

}  | Out-File $resutlsFile
if($error){
    $ProcessError | Select-Object -Property TargetObject, FullyQualifiedErrorId, ErrorDetails | Export-CSV $errorFile -NoTypeInformation
}