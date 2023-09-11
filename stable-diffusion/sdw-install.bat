@echo off
REM --------------------------------------------
REM This script was created by: Deffcolony
REM --------------------------------------------
REM Github: https://github.com/AUTOMATIC1111/stable-diffusion-webui
REM 
REM # Use this if you are running on Linux
REM python ./launch.py --xformers
REM
REM # Use this if you will be accessing the UI from a remote server
REM python ./launch.py --listen
REM
REM # Use this if you have a small amount of GPU memory 
REM python ./launch.py --medvram
REM 
REM # Use this if you have an even smaller amount of GPU memory 
REM python ./launch.py --lowvram
REM 
REM # Use this if you are running on an AMD GPU
REM python ./launch.py --precision full --no-half

title stable-difussion-webui menu
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
set "miniconda_path=%userprofile%\miniconda"


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

REM Check if Git is installed if not then install git
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_fg_strong%[WARN] Git is not installed on this system.%reset%
    echo %blue_fg_strong%[INFO]%reset% Installing Git using Winget...
    winget install -e --id Git.Git
    echo %green_fg_strong%Git is installed. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Git is already installed.%reset%
)


REM Menu Frontend
:menu
cls
echo What would you like to do?
color 7
echo 1. Install Stable Diffusion web UI
echo 2. Run Stable Diffusion web UI
echo 3. Run Stable Diffusion web UI with addons
echo 4. Exit


set "choice="
set /p "choice=Choose Your Destiny (default is 1): "

REM Default to choice 1 if no input is provided
if not defined choice set "choice=1"

REM Menu - Backend
if "%choice%"=="1" (
    call :installsdw
) else if "%choice%"=="2" (
    call :runsdwclean
) else if "%choice%"=="3" (
    call :runsdwaddons
) else if "%choice%"=="4" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :menu
)


:installsdw
cls
echo %blue_fg_strong%/ Installer / Stable Diffusion web UI%reset%
echo ---------------------------------------------------------------
echo %blue_fg_strong%[INFO]%reset% Installing Stable Diffusion web UI...
echo --------------------------------
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%


winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named stablediffusionwebui
call conda create -n stablediffusionwebui -y

REM Activate the stablediffusionwebui environment
call conda activate stablediffusionwebui

REM Install Python 3.10.6 and Git in the stablediffusionwebui environment
call conda install python=3.10.6 git -y

REM Clone the stable-diffusion-webui Extras repository
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

echo %green_fg_strong%Stable Diffusion web UI installed successfully.%reset%
pause
goto :menu

:runsdwclean
cd stable-diffusion-webui

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the sillytavernextras environment
call conda activate stablediffusionwebui

REM Start stablediffusionwebui clean
start cmd /k python ./launch.py
goto :menu


:runsdwaddons
cd stable-diffusion-webui

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the sillytavernextras environment
call conda activate stablediffusionwebui

REM Start stablediffusionwebui with desired configurations
start cmd /k python ./launch.py --autolaunch --api --listen --port 7900 --xformers --reinstall-xformers --theme dark
goto :menu