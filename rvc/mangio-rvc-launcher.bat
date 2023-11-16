@echo off
REM RVC-Launcher
REM Created by: Deffcolony
REM Github: https://github.com/Mangio621/Mangio-RVC-Fork
REM
REM Description:
REM This script installs winget, 7-zip and Mangio-RVC 
REM
REM Usage:
REM 1. install Mangio-RVC 
REM 2. Launch this script again and choose option 2 or 3 
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
setlocal

title Mangio RVC Launcher

REM ANSI Escape Code for Colors
set "reset=[0m"

REM Strong Foreground Colors
set "white_fg_strong=[90m"
set "red_fg_strong=[91m"
set "green_fg_strong=[92m"
set "yellow_fg_strong=[93m"
set "blue_fg_strong=[94m"
set "magenta_fg_strong=[95m"
set "cyan_fg_strong=[96m"

REM Normal Background Colors
set "red_bg=[41m"
set "yellow_bg=[43m"
set "blue_bg=[44m"

REM Environment Variables
set "version=v23.7.0"
set "dir=%~dp0Mangio-RVC-%version%_INFER_TRAIN\Mangio-RVC-%version%\"
REM set "logfile=%~dp0install-logs.log"

REM Environment Variables (winget)
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"

REM Environment Variables (7z)
set "zip7_install_path=%ProgramFiles%\7-Zip"

REM Define the paths and filenames for the shortcut creation
set "shortcutTarget=%~dp0mangio-rvc-launcher.bat"
set "iconFile=%~dp0mangio-rvc.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=mangio-rvc-launcher.lnk"
set "startIn=%~dp0"
set "comment=Mangio RVC Launcher"


REM Log your messages test window
REM echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Something has been launched.
REM echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] something is not installed on this system.%reset%
REM echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] An error occurred during the process.%reset%
REM pause

REM Clear log file
REM echo. > "%logfile%"

REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Winget is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Winget...
    curl -L -o "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "https://github.com/microsoft/winget-cli/releases/download/v1.6.2771/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    start "" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Winget installed successfully.%reset%
) else (
    echo %blue_fg_strong%[INFO] Winget is already installed.%reset%
)

rem Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

rem Check if the paths are already in the current PATH
echo %current_path% | find /i "%winget_path%" > nul
set "ff_path_exists=%errorlevel%"

rem Append the new paths to the current PATH only if they don't exist
if %ff_path_exists% neq 0 (
    set "new_path=%current_path%;%winget_path%"

    rem Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%new_path%" /f

    rem Update the PATH value for the current session
    setx PATH "%new_path%" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%winget added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] winget already exists in PATH.%reset%
)


REM Check if 7-Zip is installed; if not, then install it
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] 7-Zip is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing 7-Zip using Winget...
    winget install -e --id 7zip.7zip
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-Zip successfully installed.%reset%
) else (
    echo %blue_fg_strong%[INFO] 7-Zip is already installed.%reset%
)

rem Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

rem Check if the paths are already in the current PATH
echo %current_path% | find /i "%zip7_install_path%" > nul
set "zip7_path_exists=%errorlevel%"

rem Append the new paths to the current PATH only if they don't exist
if %zip7_path_exists% neq 0 (
    set "new_path=%current_path%;%zip7_install_path%"
    echo %green_fg_strong%7-Zip added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] 7-Zip already exists in PATH.%reset%
)

rem Update the PATH value in the registry
reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%new_path%" /f

rem Update the PATH value for the current session
setx PATH "%new_path%" > nul


REM home Frontend
:home
title Mangio RVC [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install Mangio RVC
echo 2. Run go-web.bat : Voice Training, Voice Cover Creation
echo 3. Run go-realtime-gui.bat : Voice Changer that is useable with Discord, Steam, etc...
echo 4. Exit

set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_mangio_rvc
) else if "%choice%"=="2" (
    call :run_goweb
) else if "%choice%"=="3" (
    call :run_gorealtime
) else if "%choice%"=="4" (
    call :uninstall_mangio_rvc
) else if "%choice%"=="5" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:install_mangio_rvc
title Mangio RVC [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install Mangio RVC%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Mangio RVC...
echo --------------------------------
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

REM Download Mangio-RVC 7z archive
curl -L -o "%~dp0mangio-rvc.7z" "https://huggingface.co/MangioRVC/Mangio-RVC-Huggingface/resolve/main/Mangio-RVC-%version%_INFER_TRAIN.7z" || (
    color 4
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Download failed.. Please try again.%reset%
    pause
    goto :home
)

REM Extract Mangio-RVC 7z archive
"%ProgramFiles%\7-Zip\7z.exe" x "%~dp0mangio-rvc.7z" -o"%~dp0Mangio-RVC" || (
    color 4
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Extraction failed.. Please try again%reset%
    pause
    goto :home
)

ren "%~dp0Mangio-RVC\Mangio-RVC-%version%" "mangio-rvc-%version%"

REM Move rvc to folder %~dp0
move /Y "%~dp0Mangio-RVC\mangio-rvc-%version%" "%~dp0mangio-rvc-%version%"

REM Remove rvc_lightweight leftovers
del "%~dp0mangio-rvc.7z"
rd /S /Q "%~dp0Mangio-RVC"

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Audiobook Maker successfully installed.%reset%

REM Ask if the user wants to create a shortcut
set /p create_shortcut=Do you want to create a shortcut on the desktop? [Y/n] 
if /i "%create_shortcut%"=="Y" (

    REM Create the shortcut
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating shortcut...
    %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command ^
        "$WshShell = New-Object -ComObject WScript.Shell; " ^
        "$Shortcut = $WshShell.CreateShortcut('%desktopPath%\%shortcutName%'); " ^
        "$Shortcut.TargetPath = '%shortcutTarget%'; " ^
        "$Shortcut.IconLocation = '%iconFile%'; " ^
        "$Shortcut.WorkingDirectory = '%startIn%'; " ^
        "$Shortcut.Description = '%comment%'; " ^
        "$Shortcut.Save()"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Shortcut created on the desktop.%reset%
    pause
)
goto :home

:run_goweb
title Mangio RVC [GO-WEB]
cls
echo %blue_fg_strong%/ Home / Run go-web.bat%reset%
echo ---------------------------------------------------------------

cd /d "%~dp0mangio-rvc-%version%"
start cmd /k go-web.bat
goto :home

:run_gorealtime
title Mangio RVC [GO-REALTIME-GUI]
cls
echo %blue_fg_strong%/ Home / Run go-realtime-gui.bat%reset%
echo ---------------------------------------------------------------

cd /d "%~dp0mangio-rvc-%version%"
start cmd /k go-realtime-gui.bat
goto :home

:uninstall_mangio_rvc
title Mangio RVC [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of Mangio RVC                                              ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the folder Mangio RVC
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Mangio RVC directory...
    cd /d "%~dp0"
    rmdir /s /q mangio-rvc-%version%

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Mangio RVC uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)