@echo off
REM --------------------------------------------
REM This script was created by: Deffcolony
REM --------------------------------------------
title Video Launcher
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

REM Environment Variables (winget)
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"


REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_fg_strong%[WARN] Winget is not installed on this system.
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

winget install -e --id VideoLAN.VLC


REM home Frontend
:home
title Video Launcher [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Start the program
echo 2. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :startvideo
) else if "%choice%"=="2" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)

:startvideo
title Video Launcher [PROGRAM]
cls
echo %blue_fg_strong%/ Home / Program%reset%
echo -------------------------------------

:numTimesInput
title Video Launcher [PROGRAM]
cls
echo %blue_fg_strong%/ Home / Program%reset%
echo -------------------------------------
set /p "numTimes=%cyan_fg_strong%How many times do you want to open the video:%reset% "

REM Check if the input is a valid number
echo %numTimes%| findstr /R "^[0-9]*$" >nul
if errorlevel 1 (
    echo %yellow_fg_strong%Please enter a valid number.%reset%
    pause
    cls
    goto :numTimesInput
)

set /p "videoFile=%cyan_fg_strong%Enter filename of video (including extension):%reset% "

for /l %%i in (1, 1, %numTimes%) do (
    powershell -Command "Start-Process -FilePath 'C:\Program Files\VideoLAN\VLC\vlc.exe' -ArgumentList '%videoFile%'"
)

goto :home