Import-Module ActiveDirectory

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

$inputfile = Get-FileName "C:\temp" "Choose a text file with a list of SamAccountNames"

$InputFilename = [IO.Path]::GetFileNameWithoutExtension($inputfile)
$InputFilepath = $inputfile | Split-Path
$OutputFile = $InputFilepath + "\" + $InputFilename + "_userinfo.txt"
$BadUserFile = $InputFilepath + "\" + $InputFilename + "_baduserlist.txt"

$GoodUsers = @()
$BadUsers = ""

   Try
   {
        $Users = Get-Content $inputfile -ErrorAction Stop
        }
    Catch
    {
        Write-Host "Could not open" $inputfile
        Exit
        }

$Headers = "CN~DisplayName~Name~GivenName~SN~SamAccountName~DistinguishedName~EmailAddress~MobilePhone~OfficePhone~Enabled~Last Logon"
$Headers | Out-File $OutputFile

$i = 1
$s = ""
foreach ($u in $Users) {
    $u = $u.trim()
    Write-Host "Working on # " $i " name: " $u
    $i++
    Try
    {
        $uobj =  Get-ADUser -Filter {SamAccountName -eq $u } -Server 00aDC02.hma.com -Properties  CN, DisplayName, Name, GivenName, SN, SamAccountName, DistinguishedName, EmailAddress, MobilePhone, OfficePhone, Enabled, lastLogonTimestamp -ErrorAction Stop
        if($uobj){
            foreach ($o in $uobj){
                $s += $o.CN + "~" + $o.DisplayName + "~" + $o.Name + "~" + $o.GivenName + "~" + $o.SN + "~" + $o.SamAccountName + "~" + $o.DistinguishedName + "~" + $o.EmailAddress + "~" + $o.MobilePhone + "~" + $o.OfficePhone + "~" + $o.Enabled + "~" + $o.lastLogonTimestamp + "`n"
                }
        }
        else{
            $BadUsers = $BadUsers + $u + "`r`n"
        }
        }
    catch
    {
        $BadUsers = $BadUsers + $u + "`r`n"
        }
    }


$BadUsers | Out-File  $BadUserFile


$s | Out-File $OutputFile -Append
        