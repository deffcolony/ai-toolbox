@echo off
REM RVC-Launcher
REM Created by: Deffcolony
REM Github: https://github.com/OpenBMB/ChatDev
REM
REM Description:
REM This script installs ChatDev
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
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
set "shortcutTarget=%~dp0chatdev-launcher.bat"
REM set "iconFile=%SystemRoot%\System32\SHELL32.dll,153"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=ChatDev-Launcher.lnk"
set "startIn=%~dp0"
set "comment=ChatDev Launcher"

REM Define variables for logging
set "log_path=%~dp0logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"


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
echo 4. Update
echo 5. Uninstall ChatDev
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_chatdev
) else if "%choice%"=="2" (
    call :configure_chatdev
) else if "%choice%"=="3" (
    call :run_chatdev
) else if "%choice%"=="4" (
    call :update_chatdev
) else if "%choice%"=="5" (
    call :uninstall_chatdev
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


:install_chatdev
title ChatDev [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install ChatDev%reset%
echo ---------------------------------------------------------------
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing ChatDev...

set max_retries=3
set retry_count=0

:retry_install_chatdev
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning the ChatDev repository...
git clone https://github.com/OpenBMB/ChatDev.git

if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_install_chatdev
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to clone repository after %max_retries% retries.%reset%
    pause
    goto :home
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda...
winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named chatdev
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment chatdev...
call conda create -n chatdev python=3.9 git -y 

REM Activate the chatdev environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment chatdev...
call conda activate chatdev

REM Navigate to the ChatDev directory
cd "%~dp0ChatDev"

REM Install Python dependencies from requirements files
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing pip requirements...
pip install -r requirements.txt

echo %green_fg_strong%ChatDev Installed Successfully.%reset%

REM Ask if the user wants to create a shortcut
set /p create_shortcut=Do you want to create a shortcut on the desktop? [Y/n] 
if /i "%create_shortcut%"=="Y" (

    REM Create the shortcut
    echo %blue_fg_strong%[INFO]%reset% Creating shortcut...
    %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command ^
        "$WshShell = New-Object -ComObject WScript.Shell; " ^
        "$Shortcut = $WshShell.CreateShortcut('%desktopPath%\%shortcutName%'); " ^
        "$Shortcut.TargetPath = '%shortcutTarget%'; " ^
        "$Shortcut.WorkingDirectory = '%startIn%'; " ^
        "$Shortcut.Description = '%comment%'; " ^
        "$Shortcut.Save()"
    echo %green_fg_strong%Shortcut created on the desktop.%reset%
    pause
)
endlocal
goto :home


:configure_chatdev
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


:run_chatdev
title ChatDev
cls
echo %blue_fg_strong%/ Home / Run ChatDev%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% ChatDev launched in a new window.
start cmd /k "title ChatDev && cd /d %~dp0ChatDev && python online_log/app.py"
goto :home


:updatesdw
title ChatDev [UPDATE]
cls
echo %blue_fg_strong%/ Home / Update%reset%
echo ---------------------------------------------------------------
echo Updating...
cd /d "%~dp0ChatDev"
REM Check if git is installed
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] git command not found in PATH. Skipping update.%reset%
    echo %red_bg%Please make sure Git is installed and added to your PATH.%reset%
) else (
    call git pull --rebase --autostash
    if %errorlevel% neq 0 (
        REM incase there is still something wrong
        echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Errors while updating. Please download the latest version manually.%reset%
    ) else (
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ChatDev updated successfully.%reset%
    )
)
pause
goto :home


:uninstall_chatdev
title ChatDev [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of ChatDev                                                 ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'chatdev'...
    call conda deactivate
    call conda remove --name chatdev --all -y
    call conda clean -a -y

    REM Remove the folder ChatDev
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the ChatDev directory...
    cd /d "%~dp0"
    rmdir /s /q ChatDev

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ChatDev uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)