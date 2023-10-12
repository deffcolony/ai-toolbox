@echo off
REM RVC-Launcher v0.0.2
REM Created by: Deffcolony
REM
REM Description:
REM This script installs winget, 7-zip and Mangio-RVC 
REM
REM Usage:
REM 1. install Mangio-RVC 
REM 2. Launch this script again and choose option 2 or 3 
REM
REM This script is intended for use on Windows systems. Please
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/rvc-easy-home
REM Issues: https://github.com/deffcolony/rvc-easy-home/issues
setlocal

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
set "blue_bg=[44m"

REM Environment Variables
set "version=v23.7.0"
set "dir=%~dp0Mangio-RVC-%version%_INFER_TRAIN\Mangio-RVC-%version%\"
set "logfile=%~dp0install-logs.log"

REM Environment Variables (winget)
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"

REM Environment Variables (7z)
set "zip7_install_path=%ProgramFiles%\7-Zip"

REM Clear log file
echo. > "%logfile%"

REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_fg_strong%[WARN] Winget is not installed on this system.%reset%
    echo %blue_fg_strong%[INFO]%reset% Installing Winget...
    bitsadmin /transfer "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" /download /priority FOREGROUND "https://github.com/microsoft/winget-cli/releases/download/v1.5.2201/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    start "" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    echo %green_fg_strong%Winget is now installed.%reset%
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
    echo %green_fg_strong%winget added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] winget already exists in PATH.%reset%
)

REM Check if 7-Zip is installed; if not, then install it
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_fg_strong%[WARN] 7-Zip is not installed on this system.%reset%
    echo %blue_fg_strong%[INFO]%reset% Installing 7-Zip using Winget...
    winget install -e --id 7zip.7zip
    echo %green_fg_strong%7-Zip installed.%reset%
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
setx PATH "%new_path%"


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
    call :installmangiorvc
) else if "%choice%"=="2" (
    call :rungoweb
) else if "%choice%"=="3" (
    call :rungorealtime
) else if "%choice%"=="4" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:installmangiorvc
title Mangio RVC [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install Mangio RVC%reset%
echo ---------------------------------------------------------------
echo %blue_fg_strong%[INFO]%reset% Installing Mangio RVC...
echo --------------------------------
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

    REM Download Mangio-RVC 7z archive
    bitsadmin /transfer "infertraindwnl" /download /priority FOREGROUND ^
    "https://huggingface.co/MangioRVC/Mangio-RVC-Huggingface/resolve/main/Mangio-RVC-%version%_INFER_TRAIN.7z" ^
    "%~dp0Mangio-RVC-%version%_INFER_TRAIN.7z" || (
        color 4
        echo [%date% %time%] ERROR: Download failed >>"%logfile%"
        echo Download failed. Check the log file at %logfile% for more information.
        pause
        exit /b 1
    )

    REM Extract Mangio-RVC 7z archive
    "%ProgramFiles%\7-Zip\7z.exe" x "%~dp0Mangio-RVC-%version%_INFER_TRAIN.7z" -o"%~dp0Mangio-RVC-%version%_INFER_TRAIN" || (
        color 4
        echo [%date% %time%] ERROR: Extraction failed >>"%logfile%"
        echo Extraction failed. 7-Zip is not installed!
        pause
        exit /b 1
    )

    REM Remove Mangio-RVC 7z archive
    del "%~dp0Mangio-RVC-%version%_INFER_TRAIN.7z"
goto :home

:rungoweb
title Mangio RVC [GO-WEB]
cls
echo %blue_fg_strong%/ Home / Run go-web.bat%reset%
echo ---------------------------------------------------------------
    if exist "%dir%\go-web.bat" (
        color a
        echo [%date% %time%] INFO: Starting RVC webui... >>"%logfile%"
        cd "%dir%"
        powershell.exe -nologo -noprofile -command "Start-Process '%dir%\go-web.bat'
    ) else (
        color 4
        echo [%date% %time%] ERROR: File not found: %dir%\go-web.bat >>"%logfile%"
        echo ERROR: File not found. Check the log file at %logfile% for more information.
        pause
    )
goto :home

:rungorealtime
title Mangio RVC [GO-REALTIME-GUI]
cls
echo %blue_fg_strong%/ Home / Run go-realtime-gui.bat%reset%
echo ---------------------------------------------------------------
    if exist "%dir%\go-realtime-gui.bat" (
        color a
        echo [%date% %time%] INFO: Starting RVC realtime gui... >>"%logfile%"
        cd "%dir%"
        powershell.exe -nologo -noprofile -command "Start-Process '%dir%\go-realtime-gui.bat'
    ) else (
        color 4
        echo [%date% %time%] ERROR: File not found: %dir%\go-realtime-gui.bat >>"%logfile%"
        echo ERROR: File not found. Check the log file at %logfile% for more information.
        pause
    )
goto :home