function Get-InstalledSoftware {
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

function Install-VCC($Software) {
    if ($Software -like "Microsoft Visual C++ 2015 Redistributable*"){ 

    }
    else {
        Write-Host "Installing VCC..."
        $ArgList = '/install /norestart'
#        Write-Host "Install File: " $Process
       Start-Process "\\lvvm202707w7\PCC\vc2015_redist.x86.exe" -ArgumentList $ArgList -Wait
    }
}

$SoftwareList = Get-InstalledSoftware
Install-VCC($SoftwareList)

    