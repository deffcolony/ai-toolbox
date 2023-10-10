@echo off
REM --------------------------------------------
REM This script was created by: Deffcolony
REM --------------------------------------------
REM Github: https://github.com/OpenBMB/ChatDev
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


REM home Frontend
:home
title ChatDev [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install ChatDev
echo 2. Configure ChatDev
echo 3. Run ChatDev webui
echo 4. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :installchatdev
) else if "%choice%"=="2" (
    call :configurechatdev
) else if "%choice%"=="3" (
    call :runchatdev
) else if "%choice%"=="4" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:installchatdev
title ChatDev [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install ChatDev%reset%
echo ---------------------------------------------------------------
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

echo %blue_fg_strong%[INFO]%reset% Installing ChatDev...

winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named chatdev
call conda create -n chatdev -y 

REM Activate the chatdev environment
call conda activate chatdev

REM Install Python 3.11 and Git in the chatdev environment
call conda install python=3.9 git -y

REM Clone the ChatDev repository
git clone https://github.com/OpenBMB/ChatDev.git

REM Navigate to the ChatDev directory
cd ChatDev

REM Install Python dependencies from requirements files
pip install -r requirements.txt

echo %green_fg_strong%ChatDev Installed Successfully.%reset%
pause
endlocal
goto :home


:configurechatdev
title ChatDev [CONFIGURE]
cls
echo %blue_fg_strong%/ Home / Configure ChatDev%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"
echo %blue_fg_strong%[INFO]%reset% Running ChatDev...

REM Activate the chatdev environment
call conda activate chatdev

cls
echo %blue_fg_strong%/ Home / Configure ChatDev%reset%
echo ---------------------------------------------------------------

REM Prompt user for project_name
set /p project_name=%yellow_fg_strong%Project name:%reset% 

REM Prompt user for description_of_your_idea
set /p description_of_your_idea=%yellow_fg_strong%Enter the description of your idea:%reset% 

REM Confirm with the user if the information is correct
set /p confirm=Is the information correct? [Y/N] 
if /i "%confirm%"=="Y" (
    REM Include the user's answers in the python run.py command
    cd /d "%~dp0ChatDev"
    start cmd /k python run.py --name "%project_name%" --task "%description_of_your_idea%"
) else (
    echo %blue_fg_strong%[INFO]%reset% Returning to home...
    goto :home
)
goto :home


:runchatdev
title ChatDev
cls
echo %blue_fg_strong%/ Run ChatDev%reset%
echo ---------------------------------------------------------------
echo %blue_fg_strong%[INFO]%reset% ChatDev has been launched.
cd /d "%~dp0ChatDev"
start cmd /k python online_log/app.py
goto :home