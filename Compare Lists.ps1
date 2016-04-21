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


$ItemsFile = Get-FileName "C:\Users\ndavis33\Documents\CHS14 Info\CHS14 Users\March 2016\GE RIS" "Choose the file with a list of items to search for"
$ItemsList = Get-Content $ItemsFile
$SearchFile = Get-FileName "C:\Users\ndavis33\Documents\CHS14 Info\CHS14 Users\March 2016\GE RIS" "Choose the file with a list to search against"
$SearchList = @{}
ForEach ($Line in Get-Content $SearchFile){
        $SearchList.Add($Line,"1")
        }

$SearchFileName = [IO.Path]::GetFileNameWithoutExtension($SearchFile)
$ItemsFileName = [IO.Path]::GetFileNameWithoutExtension($ItemsFile)
$ItemsFilePath = $ItemsFile | Split-Path
$OutStringFound = $ItemsFilePath + '\Items from ' + $ItemsFileName + ' in ' + $SearchFileName + '.txt'
$OutStringNotFound = $ItemsFilePath + '\Items from ' + $ItemsFileName + ' not in ' + $SearchFileName + '.txt'

ForEach ($Name in $ItemsList){
        If ($SearchList.ContainsKey($Name)){
            $Name | Out-File -FilePath $OutStringFound  -Append
            }
        Else{
            $Name | Out-File -FilePath $OutStringNotFound -Append
        }
        }