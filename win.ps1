# Remote Support Install (by fredystar200) - PowerShell version
# Use with: irm https://github.com/fredystar200/Remote-Support-Easy-Install/raw/main/win.ps1 | iex

function Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Restarting as Administrator..."
        Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"& '$PSCommandPath'`"" -Verb RunAs
        exit
    }
}

function Pause { Write-Host; Read-Host "Press Enter to continue..." }

function Show-Menu {
    Clear-Host
    Write-Host "==================================================="
    Write-Host "  Remote Support Install (by fredystar200)"
    Write-Host "==================================================="
    Write-Host "1. Install AnyDesk"
    Write-Host "2. Install RustDesk"
    Write-Host "3. Uninstall AnyDesk and RustDesk"
    Write-Host "==================================================="
}

function Install-AnyDesk {
    $adUrl = "https://download.anydesk.com/AnyDesk.exe"
    $adPath = "$env:TEMP\AnyDesk.exe"
    Write-Host "`nDownloading latest AnyDesk installer..."
    Invoke-WebRequest -Uri $adUrl -OutFile $adPath
    Write-Host "Installing AnyDesk silently..."
    Start-Process -Wait -FilePath $adPath -ArgumentList "--install `"$env:ProgramFiles(x86)\AnyDesk`" --silent --create-shortcut"
    Remove-Item $adPath -Force
    # Find installed path
    $exe = ""
    if (Test-Path "$env:ProgramFiles(x86)\AnyDesk\AnyDesk.exe") { $exe = "$env:ProgramFiles(x86)\AnyDesk\AnyDesk.exe" }
    elseif (Test-Path "$env:ProgramFiles\AnyDesk\AnyDesk.exe") { $exe = "$env:ProgramFiles\AnyDesk\AnyDesk.exe" }
    if ($exe) {
        # Create shortcut on Desktop
        $shortcut = "$env:USERPROFILE\Desktop\AnyDesk.lnk"
        if (-not (Test-Path $shortcut)) {
            $ws = New-Object -ComObject WScript.Shell
            $s = $ws.CreateShortcut($shortcut)
            $s.TargetPath = $exe
            $s.Save()
            Write-Host "Shortcut created on Desktop."
        }
        Write-Host "Launching AnyDesk..."
        Start-Process $exe
    } else {
        Write-Host "ERROR: AnyDesk not found after install."
    }
    Pause
}

function Install-RustDesk {
    Write-Host "`nGetting latest RustDesk installer URL..."
    $rdUrl = Invoke-RestMethod -Uri "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" | % assets | Where-Object { $_.name -like "*.msi" -and $_.name -notlike "*arm*" } | Select-Object -First 1 -ExpandProperty browser_download_url
    if (-not $rdUrl) { Write-Host "Could not get RustDesk MSI URL."; Pause; return }
    $rdPath = "$env:TEMP\rustdesk-latest.msi"
    Write-Host "Downloading RustDesk installer..."
    Invoke-WebRequest -Uri $rdUrl -OutFile $rdPath
    Write-Host "Installing RustDesk silently..."
    Start-Process msiexec.exe -ArgumentList "/i `"$rdPath`" /qn" -Wait
    Remove-Item $rdPath -Force
    # Try to launch RustDesk
    $exe = "$env:ProgramFiles\RustDesk\rustdesk.exe"
    if (-not (Test-Path $exe)) { $exe = "$env:ProgramFiles(x86)\RustDesk\rustdesk.exe" }
    if (Test-Path $exe) {
        Write-Host "Launching RustDesk..."
        Start-Process $exe
    } else {
        Write-Host "RustDesk not found after install. Please check your system."
    }
    Pause
}

function Uninstall-App ($appName) {
    $regPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    foreach ($path in $regPaths) {
        Get-ChildItem $path -ErrorAction SilentlyContinue | ForEach-Object {
            $disp = $_.GetValue('DisplayName') 2>$null
            $unstr = $_.GetValue('UninstallString') 2>$null
            if ($disp -and $disp -like "*$appName*" -and $unstr) {
                Write-Host "Uninstalling: $disp"
                try {
                    $psi = New-Object System.Diagnostics.ProcessStartInfo
                    if ($unstr -match '^"(.+?)"') {
                        $psi.FileName = $matches[1]
                        $psi.Arguments = $unstr.Substring($matches[1].Length + 2)
                    } else {
                        $parts = $unstr -split ' ', 2
                        $psi.FileName = $parts[0]
                        $psi.Arguments = if ($parts.Length -gt 1) { $parts[1] } else { "" }
                    }
                    if ($psi.FileName -like "*.msi*") {
                        $argsFixed = $psi.Arguments -replace '/I','/X'
                        $psi.FileName = 'msiexec.exe'
                        $psi.Arguments = "$argsFixed /qn /norestart"
                    } elseif ($psi.FileName -like "*.exe") {
                        if ($psi.Arguments -notmatch 'silent|/S|/VERYSILENT|/qn|/quiet') {
                            $psi.Arguments += ' /S /VERYSILENT /qn /quiet /norestart'
                        }
                    }
                    $psi.UseShellExecute = $false
                    $proc = [System.Diagnostics.Process]::Start($psi)
                    $proc.WaitForExit()
                } catch { Write-Host "Uninstall failed: $($_.Exception.Message)" }
            }
        }
    }
}

function Uninstall-All {
    Write-Host "`n======= Uninstalling AnyDesk... ======="
    Uninstall-App "AnyDesk"
    Remove-Item "$env:USERPROFILE\Desktop\AnyDesk.lnk" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles(x86)\AnyDesk" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles\AnyDesk" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "`n======= Uninstalling RustDesk... ======="
    Uninstall-App "RustDesk"
    Remove-Item "$env:ProgramFiles\RustDesk" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles(x86)\RustDesk" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host
    Write-Host "All apps uninstalled and program folders cleaned up."
    Pause
}

# -------- Main Loop --------

Ensure-Admin

while ($true) {
    Show-Menu
    $choice = Read-Host "Select an option (1/2/3)"
    switch ($choice) {
        "1" { Install-AnyDesk }
        "2" { Install-RustDesk }
        "3" { Uninstall-All }
        default {}
    }
}
