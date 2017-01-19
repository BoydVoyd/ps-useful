# Point the script to the text file
$Computers = Read-Host "Enter Location Of TXT File"

# sets the varible for the file location ei c:\temp\ThisFile.exe
$Source = Read-Host "Enter File Source"

# sets the varible for the file destination
$Destination = Read-Host "Enter File destination (windows\temp)"


# displays the computer names on screen
Get-Content $Computers | foreach {Copy-Item $Source -Destination \\$_\c$\$Destination}