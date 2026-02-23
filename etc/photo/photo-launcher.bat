@echo off
setlocal EnableDelayedExpansion
REM PHOTO-LAUNCHER Launcher
REM Created by: Deffcolony
REM
REM Description:
REM This script can edit metadata of photos in bulk mostly
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title PHOTO-LAUNCHER [STARTUP CHECK]
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
set "yellow_bg=[43m"

REM Environment Variables (photo-launcher)
set "exiftool_path=%~dp0photo-launcher-stable"
set "exiftool_list=%exiftool_path%\settings\list.txt"
set "exiftool_download_url=https://exiftool.org/exiftool-13.18_64.zip"
set "exiftool_download_path=%exiftool_path%\exiftool.zip"
set "exiftool_install_path=%exiftool_path%"
set "exiftool_settings_path=%exiftool_path%\settings"

REM Environment Variables (winget)
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"

REM Environment Variables (7-Zip)
set "zip7_version=7z2301-x64"
set "zip7_install_path=%ProgramFiles%\7-Zip"
set "zip7_download_path=%TEMP%\%zip7_version%.exe"


REM Define the paths and filenames for the shortcut creation
set "shortcutTarget=%~dp0photo-launcher.bat"
set "iconFile=%~dp0logo.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=photo-launcher.lnk"
set "startIn=%~dp0"
set "comment=photo-launcher"


REM Define variables for logging
set "log_path=%exiftool_path%\logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"

cd /d "%~dp0"

REM Check if the folder exists
if not exist "%exiftool_path%" (
    mkdir "%exiftool_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "photo-launcher-stable"  
)

REM Check if the folder exists
if not exist "%exiftool_settings_path%" (
    mkdir "%exiftool_settings_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "settings"  
)

REM Check if the file exists
if not exist "%exiftool_list%" (
    type nul > "%exiftool_list%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created file: "list.txt"  
)


REM Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

REM Check if the paths are already in the current PATH
echo %current_path% | find /i "%winget_path%" > nul
set "ff_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %ff_path_exists% neq 0 (
    set "new_path=%current_path%;%winget_path%"
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "winget_path is:%cyan_fg_strong% %winget_path%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value to activate the command on system level
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%winget added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] winget already exists in PATH.%reset%
)

REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Winget is not installed on this system.%reset%
    REM Check if the folder exists
    if not exist "%~dp0bin" (
        mkdir "%~dp0bin"
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "bin"  
    ) else (
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO] "bin" folder already exists.%reset%
    )
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Winget...
    curl -L -o "%~dp0bin\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    start "" "%~dp0bin\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Winget installed successfully. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Winget is already installed.%reset%
)

REM Check if Git is installed if not then install git
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Git is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Git using Winget...
    winget install -e --id Git.Git
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Git is installed. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Git is already installed.%reset%
)


REM Update the PATH value to activate the command for the current session
set PATH=%PATH%;%zip7_install_path%

REM Check if 7-Zip is installed
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] 7z command not found in PATH.%reset%
    echo %red_fg_strong%7-Zip is not installed or not found in the system PATH.%reset%
    title PHOTO-LAUNCHER [INSTALL-7Z]
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing 7-Zip...
    winget install -e --id 7zip.7zip

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-Zip installed successfully.%reset%
)

rem Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

rem Check if the paths are already in the current PATH
echo %current_path% | find /i "%zip7_install_path%" > nul
set "zip7_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %zip7_path_exists% neq 0 (
    set "new_path=%current_path%;%zip7_install_path%"
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "zip7_install_path is:%cyan_fg_strong% %zip7_install_path%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value to activate the command on system level
    setx PATH "!new_path!" > nul

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-zip added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] 7-Zip already exists in PATH.%reset%
)

REM Check if the file exists
if not exist "%exiftool_download_path%" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading ExifTool...
    curl -L -o "%exiftool_download_path%" "%exiftool_download_url%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Extracting ExifTool archive...
    7z x "%exiftool_download_path%" -o"%exiftool_install_path%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cleaning up downloaded archive...
    del "%exiftool_download_path%"
    goto :create_shortcut
) else (
    goto :home
)

:create_shortcut
set /p create_shortcut=Do you want to create a shortcut on the desktop? [Y/n] 
if /i "%create_shortcut%"=="Y" (
    REM Create the shortcut
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating shortcut for photo-launcher...
    %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command ^
        "$WshShell = New-Object -ComObject WScript.Shell; " ^
        "$Shortcut = $WshShell.CreateShortcut('%desktopPath%\%shortcutName%'); " ^
        "$Shortcut.TargetPath = '%shortcutTarget%'; " ^
        "$Shortcut.IconLocation = '%iconFile%'; " ^
        "$Shortcut.WorkingDirectory = '%startIn%'; " ^
        "$Shortcut.Description = '%comment%'; " ^
        "$Shortcut.Save()"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Shortcut created on the desktop.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%photo-launcher installed successfully.%reset%
    pause
    start "" photo-launcher.bat
    exit
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%photo-launcher installed successfully.%reset%
    pause
    start "" photo-launcher.bat
    exit
)

REM Change the directory
cd /d "%exiftool_path%"

pause
:home
title PHOTO-LAUNCHER [HOME]
cls
echo %blue_fg_strong%^| ^> / Home                                                     ^|%reset%
echo %blue_fg_strong% ==============================================================%reset%
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| What would you like to do?                                   ^|%reset%
echo    1. Set Geolocation for Photos
echo    2. UNINSTALL photo-launcher
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Menu Options:                                                ^|%reset%
echo    0. Exit
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^|                                                              ^|%reset%

REM Define a variable containing a single backspace character
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set "BS=%%A"

REM Set the prompt with spaces
set /p "choice=%BS%   Choose Your Destiny (default is 1): "

REM Default to choice 1 if no input is provided
if not defined choice set "choice=1"


if "%choice%"=="1" (
    call :set_geolocation
) else if "%choice%"=="2" (
    call :uninstall_photo_launcher
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    timeout /t 2 >nul
    goto :home
)

:set_geolocation
title PHOTO-LAUNCHER [SET GEOLOCATION]
cls
echo %blue_fg_strong%^| ^> / Home / Set Geolocation                                   ^|%reset%
echo %blue_fg_strong% ==============================================================%reset%
echo    Enter coordinates in Google Maps format:
echo    Example: -33.398512,-70.6524
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Menu Options:                                                ^|%reset%
echo    0. Cancel
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^|                                                              ^|%reset%

REM  Define a variable containing a single backspace character
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set "BS=%%A"

set /p "coords=%BS%   Enter coordinates: "
if "%coords%"=="0" goto :home


REM Validate coordinates format
echo !coords! | findstr /r "^-\?[0-9]\+\.[0-9]\+,-[0-9]\+\.[0-9]\+$" >nul
if %errorlevel% neq 0 (
    echo %red_bg%Invalid coordinate format!%reset%
    timeout /t 2 >nul
    goto :set_geolocation
)

REM Split coordinates
for /f "tokens=1,2 delims=," %%a in ("%coords%") do (
    set "lat=%%a"
    set "lon=%%b"
)

REM Set GPS reference values
if %lat% lss 0 (set "lat_ref=S" & set "lat=%lat:-=%") else (set "lat_ref=N")
if %lon% lss 0 (set "lon_ref=W" & set "lon=%lon:-=%") else (set "lon_ref=E")

REM Select files using PowerShell
echo Selecting files...
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $ofd = New-Object Windows.Forms.OpenFileDialog; $ofd.Multiselect = $true; $ofd.Filter = 'Image Files (*.jpg;*.jpeg;*.png;*.heic)|*.jpg;*.jpeg;*.png;*.heic'; $ofd.ShowHelp = $true; $result = $ofd.ShowDialog(); if ($result -eq 'OK') { $ofd.FileNames | Out-File 'files.txt' }"

if not exist files.txt (
    echo %red_bg%No files selected!%reset%
    timeout /t 2 >nul
    goto :set_geolocation
)

REM Process files with ExifTool
echo Updating geolocation data...
exiftool -GPSLatitude="%lat%" -GPSLatitudeRef="%lat_ref%" -GPSLongitude="%lon%" -GPSLongitudeRef="%lon_ref%" -overwrite_original @files.txt

del files.txt
echo %blue_fg_strong%Geolocation updated successfully!%reset%
timeout /t 2 >nul
goto :home


:uninstall_ytdlp
title PHOTO-LAUNCHER [UNINSTALL PHOTO-LAUNCHER]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of photo-launcher                                          ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the folder
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the photo-launcher-stable directory...
    cd /d "%~dp0"
    rmdir /s /q "%exiftool_path%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%photo-launcher has been uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)