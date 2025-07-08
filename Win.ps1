#Requires -RunAsAdministrator
param(
    [string]$App = ''
)

function Show-Menu {
    Clear-Host
    Write-Host "=== Remote Support Installer ===" -ForegroundColor Cyan
    Write-Host "1. Install AnyDesk"
    Write-Host "2. Install RustDesk"
    Write-Host "Q. Quit`n"
}

function Install-AnyDesk {
    $tempFile = "$env:TEMP\AnyDesk.exe"
    Write-Host "Downloading AnyDesk..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://download.anydesk.com/AnyDesk.exe" -OutFile $tempFile -UseBasicParsing
    Write-Host "Installing AnyDesk..." -ForegroundColor Yellow
    Start-Process $tempFile -ArgumentList "--install `"$env:ProgramFiles\AnyDesk`" --silent" -Wait -NoNewWindow
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    Write-Host "`n✅ AnyDesk installed successfully!" -ForegroundColor Green
}

function Install-RustDesk {
    $tempFile = "$env:TEMP\RustDesk.exe"
    Write-Host "Downloading RustDesk..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-x64.exe" -OutFile $tempFile -UseBasicParsing
    Write-Host "Installing RustDesk..." -ForegroundColor Yellow
    Start-Process $tempFile -ArgumentList "/S" -Wait -NoNewWindow
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    Write-Host "`n✅ RustDesk installed successfully!" -ForegroundColor Green
}

# Main execution
if (-not [string]::IsNullOrWhiteSpace($App)) {
    # Silent install mode
    switch ($App.ToLower()) {
        "anydesk" { Install-AnyDesk }
        "rustdesk" { Install-RustDesk }
        default {
            Write-Host "Invalid application specified. Valid options: AnyDesk, RustDesk" -ForegroundColor Red
            exit 1
        }
    }
    exit
}

# Interactive menu mode
do {
    Show-Menu
    $selection = Read-Host "Please choose an option"
    switch ($selection) {
        '1' { 
            Install-AnyDesk
            pause
        }
        '2' { 
            Install-RustDesk
            pause
        }
        'q' { exit }
        default {
            Write-Host "Invalid selection!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} until ($selection -eq 'q')
