param (
    [string]$inputfile = $( Read-Host "Please enter the path to a file containing a list of users by firstname, lastname " )
    )


Import-Module ActiveDirectory

$InputFilename = [IO.Path]::GetFileNameWithoutExtension($inputfile)
$InputFilepath = $inputfile | Split-Path
$OutputFile = $InputFilepath + "\" + $InputFilename + "_user_samaccountname.txt"
$BadUserFile = $InputFilepath + "\" + $InputFilename + "_baduserlist.txt"

$UserList = IMPORT-CSV $inputfile

FOREACH ($Person in $UserList){
    $f = $Person.First
    $l = $Person.Last
    "Working on " + $f + " " + $l
    $uobj = get-aduser -Filter {GivenName -eq $f -and Surname -eq $l} -Server 00aDC02.hma.com -Properties SamAccountName

        foreach($o in $uobj){
          $o.SamAccountName | Out-File $OutputFile -Append
        }
}
