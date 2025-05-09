@echo off
REM Stable Difussion Web UI Launcher
REM Created by: Deffcolony
REM Github: https://github.com/AUTOMATIC1111/stable-diffusion-webui
REM
REM Description:
REM This script can install Stable difussion Webui
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title SDWF Launcher
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
set "shortcutTarget=%~dp0sdwebuiforge-launcher.bat"
set "iconFile=%~dp0sdwebuiforge.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=sdwebuiforge-launcher.lnk"
set "startIn=%~dp0"
set "comment=Stable Diffusion Web UI Launcher"

REM Define variables for logging
set "log_path=%~dp0logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"

REM Define variables for install locations (Image Generation)
set "image_generation_dir=%~dp0image-generation"
set "sdwebuiforge_install_path=%image_generation_dir%\stable-diffusion-webui-Forge"

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
title SDWF [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install SD web UI Forge
echo 2. Install painthua
echo 3. Start SD web UI Forge
echo 4. Start SD web UI Forge + addons
echo 5. Start SD web UI Forge + share
echo 6. Start painthua
echo 7. Update
echo 8. Toolbox
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_sdwebuiforge
) else if "%choice%"=="2" (
    call :install_painthua
) else if "%choice%"=="3" (
    call :start_sdwebuiforge
) else if "%choice%"=="4" (
    call :start_sdwebuiforge_addons
) else if "%choice%"=="5" (
    call :start_sdwebuiforge_share
) else if "%choice%"=="6" (
    call :start_painthua
) else if "%choice%"=="7" (
    call :update_sdwebuiforge
) else if "%choice%"=="8" (
    call :toolbox
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


:install_sdwebuiforge
title SDBWEUI FORGE [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install Stable Diffusion web UI Forge%reset%
echo -------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Stable Diffusion web UI Forge...

REM Check if the folder exists
if not exist "%image_generation_dir%" (
    mkdir "%image_generation_dir%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "image-generation"  
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO] "image-generation" folder already exists.%reset%
)
cd /d "%image_generation_dir%"


set max_retries=3
set retry_count=0
:retry_install_sdwebuiforge
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning the stable-diffusion-webui-Forge repository...
git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git

if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_install_sdwebuiforge
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to clone repository after %max_retries% retries.%reset%
    pause
    goto :app_installer_image_generation
)
cd /d "%sdwebuiforge_install_path%"

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named sdwebuiforge
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment: %cyan_fg_strong%sdwebuiforge%reset%
call conda create -n sdwebuiforge python=3.10.6 -y

REM Activate the sdwebuiforge environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment: %cyan_fg_strong%sdwebuiforge%reset%
call conda activate sdwebuiforge

REM Install pip requirements
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing pip requirements
pip install civitdl

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Stable Diffusion WebUI Forge installed Successfully.%reset%
pause
goto :home

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

:install_painthua
title painthua [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install painthua%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing painthua...

REM Clone the painthua-flask repository
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning the painthua-flask repository...
git clone https://github.com/daswer123/painthua-flask

cd /d "%~dp0painthua-flask"

REM Create a Conda environment named painthua
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment painthua...
call conda create -n painthua python=3.10 -y

REM Activate the painthua environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment painthua...
call conda activate painthua

pip install requests

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%painthua successfully installed.%reset%
pause
goto :home

:start_painthua
title painthua
cls
echo %blue_fg_strong%/ Home / Start painthua%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the painthua environment
call conda activate painthua

REM Start painthua clean
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% painthua launched in a new window.
start cmd /k "title painthua && cd /d %~dp0painthua-flask && python app.py --listen-port 7905"
goto :home

:start_sdwebuiforge
title SDWF
cls
echo %blue_fg_strong%/ Home / Run  Forge%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the sdwebuiforge environment
call conda activate sdwebuiforge

REM Start sdwebuiforge clean
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% SD web UI Forge launched in a new window.
start cmd /k "title SDWF && cd /d %sdwebuiforge_install_path% && python launch.py"
goto :home


:start_sdwebuiforge_addons
title SDWF [ADDONS]
cls
echo %blue_fg_strong%/ Home / Start SD web UI Forge + addons%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the sdwebuiforge environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment sdwebuiforge...
call conda activate sdwebuiforge

REM Start sdwebuiforge with desired configurations
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% SD web UI Forge launched in a new window.
start cmd /k "title SDWF ADDONS && cd /d %sdwebuiforge_install_path% && python launch.py --autolaunch --api --listen --port 7900 --opt-sdp-attention --theme dark --cors-allow-origins=http://127.0.0.1:7905"
goto :home


:start_sdwebuiforge_share
title SDWF [SHARE]
cls
echo %blue_fg_strong%/ Home / Start SD web UI Forge + share%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"
echo %blue_fg_strong%[INFO]%reset% Running SD web UI Forge + share...

REM Activate the sdwebui environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment sdwebuiforge...
call conda activate sdwebuiforge

cls
echo %blue_fg_strong%/ Home / SD web UI Forge + share%reset%
echo ---------------------------------------------------------------

REM Prompt user for username
set /p username=Enter a username: 

REM Prompt user for password creation
powershell -command "$password = Read-Host 'Enter a password' -AsSecureString; $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password); $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR); Write-Output $password" > temp_pass.txt
set /p password=<temp_pass.txt
del temp_pass.txt
start cmd /k "title SDWF SHARE && cd /d %sdwebuiforge_install_path% && python launch.py --autolaunch --opt-sdp-attention --always-batch-cond-uncond --share --port 7900 --gradio-auth %username%:%password% --always-batch-cond-uncond --theme dark"
goto :home

:update_sdwebuiforge
REM Check if the folder exists
if not exist "%sdwebuiforge_install_path%" (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] stable-diffusion-webui-Forge directory not found. Skipping update.%reset%
    pause
    goto :home
)

REM Update stable-diffusion-webui-Forge
set max_retries=3
set retry_count=0

:retry_update_sdwebuiforge
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating stable-diffusion-webui-Forge...
cd /d "%sdwebuiforge_install_path%"
call git pull
if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_update_sdwebuiforge
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to update stable-diffusion-webui-Forge repository after %max_retries% retries.%reset%
    pause
    goto :home
)
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%stable-diffusion-webui-Forge updated successfully.%reset%
pause
goto :home


REM Toolbox Frontend
:toolbox
title SDWF [TOOLBOX]
cls
echo %blue_fg_strong%/ Home / Toolbox %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Enable Lobe Theme
echo 2. Disable Lobe Theme
echo 3. Uninstall SD web UI Forge
echo 4. Uninstall painthua
echo 0. Back to Home


set "toolbox_choice="
set /p "toolbox_choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM toolbox - Backend
if "%toolbox_choice%"=="1" (
    call :enable_lobe_theme
) else if "%toolbox_choice%"=="2" (
    call :disable_lobe_theme
) else if "%toolbox_choice%"=="3" (
    call :uninstall_sdwebuiforge
) else if "%toolbox_choice%"=="4" (
    call :uninstall_painthua
) else if "%toolbox_choice%"=="0" (
    call :home
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :toolbox
)


:enable_lobe_theme
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning custom theme for stable-diffusion-webui...
cd /d "%sdwebuiforge_install_path%\extensions"
git clone https://github.com/lobehub/sd-webui-lobe-theme.git
goto :toolbox

:disable_lobe_theme
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the sd-webui-lobe-theme directory...
cd /d "%sdwebuiforge_install_path%\extensions"
rmdir /s /q sd-webui-lobe-theme
goto :toolbox


:uninstall_sdwebuiforge
title SDWF [UNINSTALL SDWEBUI FORGE]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of Stable Diffusion web UI Forge                           ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda enviroment: %cyan_fg_strong%sdwebuiforge%reset%
    call conda deactivate
    call conda remove --name sdwebuiforge --all -y
    call conda clean -a -y
    
    REM Remove the folder stable-diffusion-webui
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the stable-diffusion-webui-forge directory...
    cd /d "%~dp0"
    rmdir /s /q "%sdwebuiforge_install_path%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Stable Diffusion web UI Forge has been uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)

:uninstall_painthua
title painthua [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of painthua                                                ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'painthua'...
    call conda deactivate
    call conda remove --name painthua --all -y
    call conda clean -a -y

    REM Remove the folder stable-diffusion-webui
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the painthua-flask directory...
    cd /d "%~dp0"
    rmdir /s /q painthua-flask

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%painthua uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)
