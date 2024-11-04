@echo off
REM RVC Launcher
REM Created by: Deffcolony
REM Github: https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI
REM
REM Description:
REM This script can install RVC
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title RVC Launcher
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
set "shortcutTarget=%~dp0rvc-launcher.bat"
set "iconFile=%~dp0rvc.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=rvc-launcher.lnk"
set "startIn=%~dp0"
set "comment=RVC Launcher"

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
title RVC [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install RVC
echo 2. Run go-web.bat : Voice Training, Voice Cover Creation
echo 3. Run go-realtime-gui.bat : Voice Changer that is useable with Discord, Steam, etc...
echo 4. Update
echo 5. Uninstall RVC
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_rvc
) else if "%choice%"=="2" (
    call :run_go_web
) else if "%choice%"=="3" (
    call :run_go_real_time_gui
) else if "%choice%"=="4" (
    call :update_rvc
) else if "%choice%"=="5" (
    call :uninstall_rvc
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


:install_rvc
title RVC [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install RVC%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing RVC...

set max_retries=3
set retry_count=0

:retry_install_rvc
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning the Retrieval-based-Voice-Conversion-WebUI repository...
git clone https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI.git

if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_install_rvc
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to clone repository after %max_retries% retries.%reset%
    pause
    goto :home
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda...
winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named rvc
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment rvc...
call conda create -n rvc python=3.10.6 git -y

REM Activate the rvc environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment rvc...
call conda activate rvc

REM Install pip packages that are not in requirements list
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing pip modules for GUI
pip install FreeSimpleGUI
pip install sounddevice

REM Navigate to the Retrieval-based-Voice-Conversion-WebUI directory
cd "%~dp0Retrieval-based-Voice-Conversion-WebUI"


:what_gpu
echo What is your GPU?
echo 1. NVIDIA
echo 2. AMD
echo 3. AMD/Intel (DirectML)
echo 4. Intel Arc (IPEX)


setlocal enabledelayedexpansion
chcp 65001 > nul
REM Get GPU information
for /f "skip=1 delims=" %%i in ('wmic path win32_videocontroller get caption') do (
    set "gpu_info=!gpu_info! %%i"
)

echo.
echo %blue_bg%╔════ GPU INFO ═════════════════════════════════╗%reset%
echo %blue_bg%║                                               ║%reset%
echo %blue_bg%║* %gpu_info:~1%                   ║%reset%
echo %blue_bg%║                                               ║%reset%
echo %blue_bg%╚═══════════════════════════════════════════════╝%reset%
echo.

endlocal
set /p gpu_choice=Enter number corresponding to your GPU: 

REM Check the user's response
if "%gpu_choice%"=="1" (
    REM Install pip requirements
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing modules from requirements.txt in rvc
    pip install -r requirements.txt
    call conda install -c conda-forge faiss-gpu
) else if "%gpu_choice%"=="2" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing modules from requirements-amd.txt in rvc
    pip install -r requirements-amd.txt
) else if "%gpu_choice%"=="3" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing modules from requirements-amd.txt in rvc
    pip install -r requirements-dml.txt
) else if "%gpu_choice%"=="4" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing modules from requirements-amd.txt in rvc
    pip install -r requirements-ipex.txt
) else (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR]%reset% Invalid GPU choice. Please enter a valid number.
    pause
    goto what_gpu
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%RVC successfully installed.%reset%

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


:run_go_web
title RVC [GO-WEB]
cls
echo %blue_fg_strong%/ Home / Run RVC go-web%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the rvc environment
call conda activate rvc

REM Start go-web.bat
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% SillyTavern launched in a new window.
start cmd /k "title RVC go-web && cd /d %~dp0Retrieval-based-Voice-Conversion-WebUI && python infer-web.py --port 7897" 
goto :home


:run_go_real_time_gui
title RVC [GO-REALTIME-GUI]
cls
echo %blue_fg_strong%/ Home / Run RVC go-realtime-gui%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the rvc environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment rvc...
call conda activate rvc

REM Start gui_v1.py
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% RVC Go-RealTime-GUI launched in a new window.
start cmd /k "title RVC Go-RealTime-GUI && cd /d %~dp0Retrieval-based-Voice-Conversion-WebUI && python gui_v1.py"
goto :home


:update_rvc
title RVC [UPDATE]
cls
echo %blue_fg_strong%/ Home / Update%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating Stable Difussion Web UI...
cd /d "%~dp0Retrieval-based-Voice-Conversion-WebUI"

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
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%RVC updated successfully.%reset%
    )
)
pause
goto :home


:uninstall_rvc
title RVC [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of RVC                                                     ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'rvc'...
    call conda deactivate
    call conda remove --name rvc --all -y
    call conda clean -a -y

    REM Remove the folder Retrieval-based-Voice-Conversion-WebUI
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Retrieval-based-Voice-Conversion-WebUI directory...
    cd /d "%~dp0"
    rmdir /s /q Retrieval-based-Voice-Conversion-WebUI

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%RVC uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)