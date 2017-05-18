Param(

    [string]$outputDir=(Split-Path $MyInvocation.MyCommand.Path),
    [string]$serverFile= $scriptDir + '\servers.txt'
)
$outputDir
$serverFile
$servers = Get-Content $serverFile
$servers