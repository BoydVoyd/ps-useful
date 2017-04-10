$inputfile = "C:\Scripts\Disable-Netbios\servers.txt"

Invoke-Command -ComputerName (Get-Content $inputfile) -ErrorAction SilentlyContinue -ErrorVariable ProcessError -scriptblock {
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
} | Select-Object -Property PSComputerName, NetworkInterface, NetbiosOptions | Export-Csv "D:\Script-output\Disable-Netbios\netbios script results.csv" -NoTypeInformation
if($error){
    $ProcessError | Select-Object -Property TargetObject, FullyQualifiedErrorId, ErrorDetails | Export-CSV "D:\Script-output\Disable-Netbios\netbios script exceptions.csv" -NoTypeInformation
}