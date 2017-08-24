function ActivateWindows {
    $computer = gc env:computername
    $key = “H3K9W-TQWH7-YQ2RY-G3PY8-V7988”

    $wmiLicensing = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer
    $wmiLicensing.InstallProductKey($key)

    $wmiActivation = get-wmiObject -query  "SELECT * FROM SoftwareLicensingProduct WHERE PartialProductKey <> null AND LicenseIsAddon=False" -Computername $computer | foreach {if ([int]$_.LicenseStatus -ne 1) {$_.activate()} }

    $wmiLicensing = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer
    $wmiLicensing.RefreshLicenseStatus()
}

Function Install_DesktopCentral{

    Unblock-File C:\installs\DesktopCentralAgent.msi
    $ArgList = '/i C:\Installs\DesktopCentralAgent.msi /qn TRANSFORMS="C:\Installs\DesktopCentralAgent.mst" ENABLESILENT=yes REBOOT=ReallySuppress'
    Start-Process msiexec -ArgumentList $ArgList -Wait
}

Function Install_DotNet{
    Unlock-File C:\installs\dotnet452.exe
    $ArgList = '/q /norestart'
    Start-Process C:\Installs\dotnet452.exe -ArgumentList $ArgList -Wait
}

Function Install_iSeries{
    Unblock-File C:\Installs\IBM\iSeries7r1\image64a\setup.exe
    $ArgsList = '/S /v"REBOOT=REALLYSUPPRESS ADDLOCAL=ALL CWBPRIMARYLANG=MRI2924" /v/qb /s'
    Start-Process C:\Installs\IBM\iSeries7r1\image64a\setup.exe -ArgumentList $ArgsList -Wait
}

Function Install_Office{
	Unlock-File C:\installs\office2007\setup.exe
	$ArgList = '/adminfile C:\installs\office2007\updates\autoinstall.MSP'
	Start-Process C:\installs\office2007\setup.exe -ArgumentList $ArgList -Wait	
    
    Write-Output "Installing SP3"
    unblock-file C:\installs\office2007\SP3.exe
    $ArgList = '/quiet'
    Start-Process C:\installs\office2007\SP3.exe -ArgumentList $ArgList -Wait

}

Function Install_BD{
    Unlock-File "C:\installs\espkit_x64.exe"
    $ArgList = '/bdparams /silent'
    Start-Process C:\installs\espkit_x64.exe -ArgumentList $ArgList -Wait

}

Function Install_WMF4.0 {
    $ArgList = "C:\installs\wmf4.msu /quiet /norestart"
    Start-process wusa.exe -ArgumentList $ArgList -Wait
    Write-Output "Enabling PSRemoting..."
    Try {   Enable-PSRemoting -Force    }
    Catch [System.InvalidOperationException] { pause }
    # Not entirely sure we need or want to do this, so here for easy addition
    # Catch [System.InvalidOperationException] { netsh advfirewall firewall add rule name="WinRM (HTTPS)" protocol=TCP dir=in localport=5986 action=allow }

}

Function Install_VisualCRedist86 {
# check this key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress
    While (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress')
    {
        Write-Host "Another install in progress waiting for completion..."
        start-sleep -s 60
    }
    Get-ChildItem 'HKLM:\\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer' -Exclude 'Folders' | Add-Content C:\programdata\vcrlog.txt
    Unblock-File C:\Installs\IBM\VCR\VCRedist_x86\vcredist.msi
    $ArgList = "/i C:\Installs\IBM\VCR\VCRedist_x86\vcredist.msi /qb"
    Start-Process msiexec -ArgumentList $ArgList -Wait
}

Function Install_VisualCRedist64 {
    While (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress')
    {
        Write-Host "Another install in progress waiting for completion..."
        start-sleep -s 60
    }

    Get-ChildItem 'HKLM:\\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer' -Exclude 'Folders' | Add-Content C:\programdata\vcrlog.txt
    Unblock-File C:\Installs\IBM\VCR\VCRedist_x64\vcredist.msi
    $ArgList = "/i C:\Installs\IBM\VCR\VCRedist_x64\vcredist.msi /qb"
    Start-Process msiexec -ArgumentList $ArgList -Wait
}


function ListSoftware {
$SoftwareList = @()
$Properties = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName
$Properties = $Properties + $(Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName)
    foreach ($Title in $Properties)
    {
        if ($Title.DisplayName.Length -gt 1 )
        {
            $SoftWareList += $Title.DisplayName
        }
    }
    return $SoftwareList
}

function RenameComputer {
$Serial = $(gwmi win32_bios).SerialNumber
# Check Serial has data, otherwise generate a random number with an error (user can manually rename later if desired)
if ($Serial.Length -lt 1)
{
    Write-Host -Foregroundcolor Red "Could not get serial number, creating random"
    $Serial = "-SNERR"+(Get-Random -Minimum 100 -Maximum 999)

}
# Otherwise, make sure the serial isn't too long, and crop the start if it is
elseif ($Serial.Length -gt 8)
{
    $Serial=$Serial.Substring($Serial.length - 8, 8)
}

$ComputerName = "UTT" + $Serial
Rename-Computer -NewName $ComputerName
}

function SetPagefile {
    $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
    $computersys.AutomaticManagedPagefile = $False
    $computersys.Put()

    $pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name='c:\\pagefile.sys'"
    $pagefile.InitialSize = [int](12150)
    $pagefile.MaximumSize = [int](12150)
    $pagefile.Put()
}

Function setPowerPlan {
    powercfg -import "C:\programdata\ingram.pow" fbd1eeb4-9232-4dee-ae16-5650c76a3372
    powercfg -setactive fbd1eeb4-9232-4dee-ae16-5650c76a3372
}

function Unlock-File {
    [cmdletbinding(DefaultParameterSetName="ByName", SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$true, ParameterSetName="ByName", Position=0)] [string] $FilePath,
        [parameter(Mandatory=$true, ParameterSetName="ByInput", ValueFromPipeline=$true)] $InputObject
    )
    begin {
        Add-Type -Namespace Win32 -Name PInvoke -MemberDefinition @"
        // http://msdn.microsoft.com/en-us/library/windows/desktop/aa363915(v=vs.85).aspx
        [DllImport("kernel32", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool DeleteFile(string name);
        public static int Win32DeleteFile(string filePath) {
            bool is_gone = DeleteFile(filePath); return Marshal.GetLastWin32Error();}
 
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        static extern int GetFileAttributes(string lpFileName);
        public static bool Win32FileExists(string filePath) {return GetFileAttributes(filePath) != -1;}
"@
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByName'  {$input_paths = Resolve-Path -Path $FilePath | ? {[IO.File]::Exists($_.Path)} | Select -Exp Path}
            'ByInput' {if ($InputObject -is [System.IO.FileInfo]) {$input_paths = $InputObject.FullName}}
        }
        $input_paths | % {     
            if ([Win32.PInvoke]::Win32FileExists($_ + ':Zone.Identifier')) {
                if ($PSCmdlet.ShouldProcess($_)) {
                    $result_code = [Win32.PInvoke]::Win32DeleteFile($_ + ':Zone.Identifier')
                    if ([Win32.PInvoke]::Win32FileExists($_ + ':Zone.Identifier')) {
                        Write-Error ("Failed to unblock '{0}' the Win32 return code is '{1}'." -f $_, $result_code)
                    }
                }
            }
        }
    }
}

$InstalledSoftware = ListSoftware

Write-Output "Checking Powerplan..."
if ( $(gwmi -Class Win32_PowerPlan -Namespace "root\cimv2\power" | Where-Object {$_.isActive -eq $true}).InstanceID -ne "Microsoft:PowerPlan\{fbd1eeb4-9232-4dee-ae16-5650c76a3372}")
{
    Write-Output "Powerplan not set, setting"
    setPowerPlan
    # Stop-Computer
    Restart-Computer
    pause
}
else {
    Write-Output "OK."
}


write-output "Checking for .NET 4.5..."
If ($InstalledSoftware -notcontains 'Microsoft .NET Framework 4.5.2')
{
    write-output "Not Found, Installing."
    Install_DotNet
    # Stop-Computer
    # pause
    Restart-Computer
    pause

}
else
{
	write-output "OK"
}

write-output "Checking for Powershell 4.0..."
If ( ($PSVersionTable.PSVersion.Major -lt 4) -and ($InstalledSoftware -like 'Microsoft .NET Framework 4.5*'))
{
   write-output "Not Found, Installing."
   Install_WMF4.0
   Restart-Computer
   pause
}
else
{
	write-output "OK"
}

#Rename computer

write-output "Checking for Bitdefender..."
if ($InstalledSoftware -notcontains "Bitdefender Endpoint Security Tools")
{
    write-output "Not Found, Installing."
    Install_BD

    $ArgList = '/quiet /norestart'
    $DotNetUpdate = Get-ChildItem -Path C:\Updates\NDP45*.exe
    foreach ($Update in $DotNetUpdate)
    {
        Start-Process $Update -ArgumentList $ArgList -wait
        Remove-Item $Update
    }

    # $arglist = 'C:\Updates\Windows6.1-KB2972211-x64.msu /q /norestart'
    # Start-Process wusa.exe -ArgumentList $ArgList -wait
    
    While (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress')
    {
        Write-Host "Install in progress, waiting for completion for restart"
        start-sleep -s 60
    }
    Write-Host "Restarting"

    Restart-Computer
    pause
}
else
{
	write-output "OK"
}

start-sleep -s 5

write-output "Checking for Desktop Central..."
if ($InstalledSoftware -notcontains "ManageEngine Desktop Central - Agent")
{
    write-output "Not Found, Installing."
    Install_DesktopCentral
    start-sleep -s 60
    Restart-Computer
    pause
}
else
{
	write-output "OK"
}

start-sleep -s 2

# write-output "Checking for Office..."
# if ($InstalledSoftware -notcontains "Microsoft Office Standard 2007")
#{
#    write-output "Not Found, Installing."
#    Install_Office
#}
#else
#{
#	write-output "OK"
#}

Write-Output "Checking for Visual C++ 2005 Redistributable..."
if ($InstalledSoftware -notcontains "Microsoft Visual C++ 2005 Redistributable")
{
    write-output "Not Found, Installing."
    Install_VisualCRedist86
}
else
{
	write-output "OK"
}

Write-Output "Checking for Visual C++ 2005 Redistributable (x64) ..."
if ($InstalledSoftware -notcontains "Microsoft Visual C++ 2005 Redistributable (x64)")
{
    write-output "Not Found, Installing."
    Install_VisualCRedist64
    Restart-Computer -force
    pause
}
else
{
	write-output "OK"
}

Write-Output "Checking for IBM iSeries..."
if ($InstalledSoftware -notcontains "IBM i Access for Windows 7.1")
{
    Write-Output "Not Found, Installing"
    Install_iSeries
    Restart-Computer
    pause
}
else
{
    Write-Output "OK."
}


# Join Domain

# Finish up iSeries


# Here we'd check for work done to make sure we're ready to clean

Write-Output "Setting license and activating"
ActivateWindows


Write-Output "Renaming computer"
RenameComputer


Write-Output "Setting Pagefile"
SetPagefile


if ( ($PSVersionTable.PSVersion.Major -ge 4) -and 
($InstalledSoftware -contains 'Microsoft .NET Framework 4.5.2')  -and 
($InstalledSoftware -contains "Bitdefender Endpoint Security Tools") -and 
# ($InstalledSoftware -contains "Microsoft Office Standard 2007") -and 
($InstalledSoftware -contains "Microsoft Visual C++ 2005 Redistributable") -and 
($InstalledSoftware -contains "Microsoft Visual C++ 2005 Redistributable (x64)") -and 
($InstalledSoftware -contains "IBM i Access for Windows 7.1") ) {
    Write-Output "Installs complete, cleaning up."

    Write-Output "Deleting Install files."
    Remove-Item C:\installs -Force -Recurse

    Write-Output "Deleting Autolaunch"
    del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\startup.bat"

    Write-Output "Changing Autolaunch to Domain Join"
    Set-Content -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\startup.bat" -Value ('powershell -f C:\join.ps1') -Force

    Write-Output "Removing This Script"
    Remove-Item C:\automated.ps1

    Restart-Computer
}