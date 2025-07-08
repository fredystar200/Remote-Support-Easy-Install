@echo off
:: Self-elevate to admin if not already
openfiles >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/c cd ""%~sdp0"" && %~s0 %*", "", "runas", 1 > "%temp%\getadmin.vbs"
    cscript //nologo "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)
setlocal enableextensions

:menu
cls
echo ==================================================
echo   Remote Support Install (by fredystar200)
echo ==================================================
echo 1. Install AnyDesk
echo 2. Install RustDesk
echo 3. Uninstall AnyDesk and RustDesk
echo ==================================================
set /p choice="Select an option (1/2/3): "

if "%choice%"=="1" goto anydesk
if "%choice%"=="2" goto rustdesk
if "%choice%"=="3" goto uninstall
goto menu

:anydesk
echo.
echo Downloading latest AnyDesk installer...
set "ADLNK=https://download.anydesk.com/AnyDesk.exe"
set "ADSETUP=%temp%\AnyDesk.exe"
powershell -Command "Invoke-WebRequest -Uri '%ADLNK%' -OutFile '%ADSETUP%'"
echo Installing AnyDesk silently...
start /wait "" "%ADSETUP%" --install "%ProgramFiles(x86)%\AnyDesk" --silent --create-shortcut
echo Cleaning up installer...
del "%ADSETUP%"

REM Detect where AnyDesk got installed
set "ANYDESK_EXE="
if exist "%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe" (
    set "ANYDESK_EXE=%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe"
)
if not defined ANYDESK_EXE if exist "%ProgramFiles%\AnyDesk\AnyDesk.exe" (
    set "ANYDESK_EXE=%ProgramFiles%\AnyDesk\AnyDesk.exe"
)

setlocal enabledelayedexpansion
if defined ANYDESK_EXE (
    set "SHORTCUT=%USERPROFILE%\Desktop\AnyDesk.lnk"
    if not exist "!SHORTCUT!" (
        powershell -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('!SHORTCUT!');$s.TargetPath='!ANYDESK_EXE!';$s.Save()"
        echo Shortcut created on Desktop.
    )
    echo Launching AnyDesk...
    start "" "!ANYDESK_EXE!"
) else (
    echo ERROR: AnyDesk was not found after install. No shortcut created.
)
endlocal

echo.
pause
goto menu

:rustdesk
echo.
echo Getting latest RustDesk installer URL...
for /f "tokens=*" %%i in ('powershell -Command "Invoke-RestMethod -Uri https://api.github.com/repos/rustdesk/rustdesk/releases/latest | Select-Object -ExpandProperty assets | Where-Object { $_.name -like '*.msi' -and $_.name -notlike '*arm*' } | Select-Object -First 1 -ExpandProperty browser_download_url"') do set "RDLNK=%%i"
set "RDSETUP=%temp%\rustdesk-latest.msi"
echo Downloading RustDesk installer...
powershell -Command "Invoke-WebRequest -Uri '%RDLNK%' -OutFile '%RDSETUP%'"
echo Installing RustDesk silently...
msiexec /i "%RDSETUP%" /qn
echo Cleaning up installer...
del "%RDSETUP%"

REM Try to find and launch RustDesk after install
set "RUSTDESK_EXE=%ProgramFiles%\RustDesk\rustdesk.exe"
if not exist "%RUSTDESK_EXE%" set "RUSTDESK_EXE=%ProgramFiles(x86)%\RustDesk\rustdesk.exe"
if exist "%RUSTDESK_EXE%" (
    echo Launching RustDesk...
    start "" "%RUSTDESK_EXE%"
) else (
    echo RustDesk was not found in the default location. Please check your system.
)

echo.
pause
goto menu

:uninstall
echo.
echo ======= Uninstalling AnyDesk... =======
call :robust_uninstall "AnyDesk"
del "%USERPROFILE%\Desktop\AnyDesk.lnk" >nul 2>&1
rmdir /s /q "%ProgramFiles(x86)%\AnyDesk" >nul 2>&1
rmdir /s /q "%ProgramFiles%\AnyDesk" >nul 2>&1

echo ======= Uninstalling RustDesk... =======
call :robust_uninstall "RustDesk"
rmdir /s /q "%ProgramFiles%\RustDesk" >nul 2>&1
rmdir /s /q "%ProgramFiles(x86)%\RustDesk" >nul 2>&1

echo.
echo All apps uninstalled and program folders cleaned up.
pause
goto menu

:robust_uninstall
powershell -NoProfile -Command "$appName = '%1'; $regPaths = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'); foreach ($path in $regPaths) { Get-ChildItem $path -ErrorAction SilentlyContinue | ForEach-Object { $disp = $_.GetValue('DisplayName') 2>&1; $unstr = $_.GetValue('UninstallString') 2>&1; if ($disp -and $disp -like ('*' + $appName + '*') -and $unstr) { Write-Host 'Uninstalling: ' $disp; try { $psi = New-Object System.Diagnostics.ProcessStartInfo; if ($unstr -match '^\"(.+?)\"') { $psi.FileName = $matches[1]; $psi.Arguments = $unstr.Substring($matches[1].Length+2); } else { $psi.FileName, $psi.Arguments = $unstr -split ' ', 2; } if ($psi.FileName -like '*.msi*') { $argsFixed = $psi.Arguments -replace '/I','/X'; $psi.FileName = 'msiexec.exe'; $psi.Arguments = \"$argsFixed /qn /norestart\"; } elseif ($psi.FileName -like '*.exe') { if ($psi.Arguments -notmatch 'silent|/S|/VERYSILENT|/qn|/quiet') { $psi.Arguments += ' /S /VERYSILENT /qn /quiet /norestart'; } } $psi.UseShellExecute = $false; $proc = [System.Diagnostics.Process]::Start($psi); $proc.WaitForExit(); } catch { Write-Host 'Uninstall failed:' $_.Exception.Message } } } }"
exit /b

