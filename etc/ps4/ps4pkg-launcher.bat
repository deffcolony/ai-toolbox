@echo off
REM PS4 PKG Viewer
REM Created by: Deffcolony
REM
REM Description:
REM This script is a tool to extract and dump ps4 pkg files
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title PS4 PKG Viewer
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

REM Environment Variables (TOOLBOX Install Extras)
set "miniconda_path=%userprofile%\miniconda3"

REM Define the paths and filenames for the shortcut creation
set "shortcutTarget=%~dp0ps4pkg-launcher.bat"
set "iconFile=%~dp0ps4pkg.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=ps4pkg-launcher.lnk"
set "startIn=%~dp0"
set "comment=PS4 PKG Viewer"

REM Define variables for logging
set "log_path=%~dp0logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"

cd /d "%~dp0"


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

    REM Update the PATH value for the current session
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
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Winget...
    curl -L -o "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    start "" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
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
    echo echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Git is installed. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Git is already installed.%reset%
)


REM home Frontend
:home
title PS4 PKG Viewer [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install PS4 PKG Viewer
echo 2. Dump all contents from pkg to folder
echo 3. Extract all contents from pkg to xml
echo 4. Uninstall PS4 PKG Viewer
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_ps4pkgviewer
) else if "%choice%"=="2" (
    call :run_ps4pkgviewer_dump
) else if "%choice%"=="3" (
    call :run_ps4pkgviewer_extract
) else if "%choice%"=="4" (
    call :uninstall_ps4pkgviewer
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)

:install_ps4pkgviewer
title PS4 PKG Viewer [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install PS4 PKG Viewer%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing PS4 PKG Viewer...
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda...
winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named ps4pkgviewer
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment: %cyan_fg_strong%ps4pkgviewer%reset%
call conda create -n ps4pkgviewer python=3.12 -y

REM Activate the conda environment named ps4pkgviewer 
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment: %cyan_fg_strong%ps4pkgviewer%reset%
call conda activate ps4pkgviewer

set max_retries=3
set retry_count=0

:retry_install_ps4pkgviewer
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning the PS4-pkg-viewer repository...
git clone https://github.com/Oxwald/PS4-pkg-viewer.git

if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_install_ps4pkgviewer
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to clone repository after %max_retries% retries.%reset%
    pause
    goto :app_installer_text_completion
)
cd /d "PS4-pkg-viewer"


REM Install pip requirements
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing pip requirements
pip install tk
pip install Pillow

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%PS4 PKG Viewer installed.%reset%

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


:run_ps4pkgviewer_dump
title PS4 PKG Viewer [DUMP CONTENTS]
cls
echo %blue_fg_strong%/ Home / Dump all contents from pkg to folder%reset%
echo -------------------------------------

REM Activate the ps4pkgviewer environment
call conda activate ps4pkgviewer

REM Run the extract program
cd /d "%~dp0PS4-pkg-viewer"
cls
set /p dmpkgname="(0 to cancel)Insert .pkg filename: "

if "%dmpkgname%"=="0" goto :home

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Dumping all contents from %dmpkgname% to: "%~dp0PS4-pkg-viewer\extracted"
start cmd /k python main.py dump %dmpkgname% --out extracted
goto :home


:run_ps4pkgviewer_extract
title PS4 PKG Viewer [EXTRACT TO XML]
cls
echo %blue_fg_strong%/ Home / Extract all contents from pkg to xml%reset%
echo -------------------------------------

REM Activate the ps4pkgviewer environment
call conda activate ps4pkgviewer

REM Run the extract program
cd /d "%~dp0PS4-pkg-viewer"
cls
set /p extpkgname="(0 to cancel)Insert .pkg filename: "

if "%extpkgname%"=="0" goto :home

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Extracting %extpkgname% to out.xml...
start cmd /k python main.py extract %extpkgname% --file 0x126C --out out.xml
goto :home


:uninstall_ps4pkgviewer
title PS4 PKG Viewer [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of PS4 PKG Viewer                                          ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'ps4pkgviewer'...
    call conda deactivate
    call conda remove --name ps4pkgviewer --all -y
    call conda clean -a -y

    REM Remove the folder ps4pkgviewer
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the ps4pkgviewer directory...
    cd /d "%~dp0"
    rmdir /s /q PS4-pkg-viewer

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%PS4 PKG Viewer uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)