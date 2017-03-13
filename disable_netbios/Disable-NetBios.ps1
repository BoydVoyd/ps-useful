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

#$mydocs = [Environment]::GetFolderPath("MyDocuments")
$inputfile = Get-FileName  "C:\Users\ndavis\Source\Repos\psuseful" "Choose a text file with a list computers"

$inputfile
