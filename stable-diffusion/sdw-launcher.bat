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
title SD Web UI Launcher
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

REM Define the paths and filenames for the shortcut creation
set "shortcutTarget=%~dp0sdw-launcher.bat"
set "iconFile=%~dp0sdw.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=sdw-launcher.lnk"
set "startIn=%~dp0"
set "comment=Stable Diffusion Web UI Launcher"


REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Winget is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Winget...
    bitsadmin /transfer "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" /download /priority FOREGROUND "https://github.com/microsoft/winget-cli/releases/download/v1.5.2201/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
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
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%winget successfully added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] winget already exists in PATH.%reset%
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
title SD Web UI [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install SD web UI
echo 2. Run SD web UI
echo 3. Run SD web UI + addons
echo 4. Run SD web UI + share
echo 5. Update
echo 6. Toolbox
echo 7. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_sdw
) else if "%choice%"=="2" (
    call :run_sdw
) else if "%choice%"=="3" (
    call :run_sdw_addons
) else if "%choice%"=="4" (
    call :run_sdw_share
) else if "%choice%"=="5" (
    call :update_sdw
) else if "%choice%"=="6" (
    call :toolbox
) else if "%choice%"=="7" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:install_sdw
title SD Web UI [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install SD web UI%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Stable Diffusion web UI...
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda...
winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named stablediffusionwebui
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment stablediffusionwebui...
call conda create -n stablediffusionwebui -y

REM Activate the stablediffusionwebui environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment stablediffusionwebui...
call conda activate stablediffusionwebui

REM Install Python 3.10.6 and Git in the stablediffusionwebui environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Python and Git in the Conda environment...
call conda install python=3.10.6 git -y

REM Clone the stable-diffusion-webui Extras repository
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning the stable-diffusion-webui repository...
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

REM Clone extensions for stable-diffusion-webui
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning extensions for stable-diffusion-webui...
cd /d "%~dp0stable-diffusion-webui/extensions"
git clone https://github.com/alemelis/sd-webui-ar.git
git clone https://github.com/butaixianran/Stable-Diffusion-Webui-Civitai-Helper.git
git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git
git clone https://github.com/EnsignMK/danbooru-prompt.git
git clone https://github.com/fkunn1326/openpose-editor.git
git clone https://github.com/Mikubill/sd-webui-controlnet.git
git clone https://github.com/ashen-sensored/sd_webui_SAG.git
git clone https://github.com/NoCrypt/sd-fast-pnginfo.git
git clone https://github.com/Bing-su/adetailer.git
git clone https://github.com/hako-mikan/sd-webui-supermerger.git
git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git
git clone https://github.com/hako-mikan/sd-webui-regional-prompter.git
git clone https://github.com/Gourieff/sd-webui-reactor.git
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-rembg.git




REM Installs better upscaler models
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Better Upscaler models...
cd /d "%~dp0stable-diffusion-webui/models"
mkdir ESRGAN && cd ESRGAN
curl -o 4x-AnimeSharp.pth https://huggingface.co/konohashinobi4/4xAnimesharp/resolve/main/4x-AnimeSharp.pth
curl -o 4x-UltraSharp.pth https://huggingface.co/lokCX/4x-Ultrasharp/resolve/main/4x-UltraSharp.pth

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Stable Diffusion web UI successfully installed.%reset%

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


:run_sdw
title SD web UI
cls
echo %blue_fg_strong%/ Home / Run SD web UI%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the sillytavernextras environment
call conda activate stablediffusionwebui

REM Start stablediffusionwebui clean
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% SillyTavern launched in a new window.
start cmd /k "title SD web UI && cd /d %~dp0stable-diffusion-webui && python launch.py"
goto :home


:run_sdw_addons
title SD web UI [ADDONS]
cls
echo %blue_fg_strong%/ Home / Run SD web UI + addons%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the sillytavernextras environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment stablediffusionwebui...
call conda activate stablediffusionwebui

REM Start stablediffusionwebui with desired configurations
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% SillyTavern launched in a new window.
start cmd /k "title SD web UI ADDONS && cd /d %~dp0stable-diffusion-webui && python launch.py --autolaunch --api --listen --port 7900 --opt-sdp-attention --theme dark"
goto :home


:run_sdw_share
title SD web UI [SHARE]
cls
echo %blue_fg_strong%/ Home / Run SD web UI + share%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"
echo %blue_fg_strong%[INFO]%reset% Running SD web UI + share...

REM Activate the stablediffusionwebui environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment stablediffusionwebui...
call conda activate stablediffusionwebui

cls
echo %blue_fg_strong%/ Home / SD web UI + share%reset%
echo ---------------------------------------------------------------

REM Prompt user for username
set /p username=Enter a username: 

REM Prompt user for password creation
powershell -command "$password = Read-Host 'Enter a password' -AsSecureString; $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password); $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR); Write-Output $password" > temp_pass.txt
set /p password=<temp_pass.txt
del temp_pass.txt
start cmd /k "title SD web UI SHARE && cd /d %~dp0stable-diffusion-webui && python launch.py --autolaunch --opt-sdp-attention --always-batch-cond-uncond --share --port 7900 --gradio-auth %username%:%password% --always-batch-cond-uncond --theme dark"
goto :home

:update_sdw
title SD web UI [UPDATE]
cls
echo %blue_fg_strong%/ Home / Update%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating Stable Difussion Web UI...
cd /d "%~dp0stable-diffusion-webui"

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
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Stable Diffusion Web UI updated successfully.%reset%
    )
)
pause
goto :home


REM Toolbox Frontend
:toolbox
title SD Web UI [TOOLBOX]
cls
echo %blue_fg_strong%/ Home / Toolbox %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Enable Lobe Theme
echo 2. Disable Lobe Theme
echo 3. Uninstall SD web UI
echo 4. Back to Home




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
    call :uninstall_sdw
) else if "%toolbox_choice%"=="4" (
    call :home
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :toolbox
)


:enable_lobe_theme
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning custom theme for stable-diffusion-webui...
cd /d "%~dp0stable-diffusion-webui/extensions"
git clone https://github.com/lobehub/sd-webui-lobe-theme.git
goto :toolbox

:disable_lobe_theme
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the sd-webui-lobe-theme directory...
cd /d "%~dp0stable-diffusion-webui/extensions"
rmdir /s /q sd-webui-lobe-theme
goto :toolbox


:uninstall_sdw
title SD web UI [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of Stable Difussion Web UI                                 ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'stablediffusionwebui'...
    call conda remove --name stablediffusionwebui --all -y

    REM Remove the folder stable-diffusion-webui
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the stable-diffusion-webui directory...
    cd /d "%~dp0"
    rmdir /s /q stable-diffusion-webui

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Stable Diffusion Web UI uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)