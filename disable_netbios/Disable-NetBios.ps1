Function Get-FileName($initialDirectory,$Title)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.title = $Title
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv|TXT (*.txt)|*.txt"
    $OpenFileDialog.filterindex = 2
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}


$startfolder = [Environment]::GetFolderPath("MyDocuments")
$inputfile = Get-FileName  $startfolder "Choose a text file with a list computers"

Set-Location $startfolder

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
} | Select-Object -Property PSComputerName, NetworkInterface, NetbiosOptions | Export-Csv ".\netbios script results.csv" -NoTypeInformation
if($error){
    $ProcessError | Select-Object -Property TargetObject, FullyQualifiedErrorId, ErrorDetails | Export-CSV ".\netbios script exceptions.csv" -NoTypeInformation
}