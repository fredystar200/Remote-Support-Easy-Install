#Requires -RunAsAdministrator
param(
    [ValidateSet('AnyDesk','RustDesk')]
    [string]$App = 'AnyDesk'
)

Clear-Host
Write-Host "=== Remote Support Installer for Windows ===" -ForegroundColor Cyan
Write-Host "Selected Application: $App`n"

function Install-AnyDesk {
    $tempFile = "$env:TEMP\AnyDesk.exe"
    Write-Host "Downloading AnyDesk..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://download.anydesk.com/AnyDesk.exe" -OutFile $tempFile
    Write-Host "Installing AnyDesk..." -ForegroundColor Yellow
    Start-Process $tempFile -ArgumentList "--install `"$env:ProgramFiles\AnyDesk`" --silent" -Wait
    Remove-Item $tempFile -Force
}

function Install-RustDesk {
    $tempFile = "$env:TEMP\RustDesk.exe"
    Write-Host "Downloading RustDesk..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-x64.exe" -OutFile $tempFile
    Write-Host "Installing RustDesk..." -ForegroundColor Yellow
    Start-Process $tempFile -ArgumentList "/S" -Wait
    Remove-Item $tempFile -Force
}

try {
    switch ($App) {
        'AnyDesk' { Install-AnyDesk }
        'RustDesk' { Install-RustDesk }
    }
    
    Write-Host "`nInstallation completed successfully!" -ForegroundColor Green
    Write-Host "Please launch $App to start your remote session." -ForegroundColor Green
}
catch {
    Write-Host "`nError occurred: $_" -ForegroundColor Red
    Write-Host "Please try manually downloading from:" -ForegroundColor Yellow
    if ($App -eq 'AnyDesk') {
        Write-Host "https://anydesk.com/en/download"
    } else {
        Write-Host "https://rustdesk.com/en/download"
    }
}