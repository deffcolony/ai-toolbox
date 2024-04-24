@echo off
REM ComfyUI Launcher
REM Created by: Deffcolony
REM Github: https://github.com/comfyanonymous/ComfyUI
REM
REM Description:
REM This script can install ComfyUI
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title ComfyUI Launcher
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
set "shortcutTarget=%~dp0comfyui-launcher.bat"
set "iconFile=%~dp0comfyui.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=comfyui-launcher.lnk"
set "startIn=%~dp0"
set "comment=ComfyUI Launcher"


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
title ComfyUI [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install ComfyUI
echo 2. Run ComfyUI
echo 3. Update
echo 4. Toolbox
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_comfyui
) else if "%choice%"=="2" (
    call :run_comfyui
) else if "%choice%"=="3" (
    call :update_comfyui
) else if "%choice%"=="4" (
    call :toolbox
) else if "%choice%"=="0" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:install_comfyui
title ComfyUI [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install ComfyUI%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing ComfyUI...
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda...
winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named comfyui
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment comfyui...
call conda create -n comfyui -y

REM Activate the comfyui environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment comfyui...
call conda activate comfyui

REM Install Python 3.11 and Git in the comfyui environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Python and Git in the Conda environment...
call conda install python=3.11 git -y

REM Clone the ComfyUI repository
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning the ComfyUI repository...
git clone https://github.com/comfyanonymous/ComfyUI.git

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing pip requirements...
cd /d "%~dp0ComfyUI"
pip install -r requirements.txt
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121

REM Clone extensions for ComfyUI
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning extensions for ComfyUI...
cd /d "%~dp0ComfyUI/custom_nodes"
git clone https://github.com/ltdrdata/ComfyUI-Manager.git


REM Installs better upscaler models
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Better Upscaler models...
cd /d "%~dp0ComfyUI/models"
mkdir ESRGAN && cd ESRGAN
curl -o 4x-AnimeSharp.pth https://huggingface.co/konohashinobi4/4xAnimesharp/resolve/main/4x-AnimeSharp.pth
curl -o 4x-UltraSharp.pth https://huggingface.co/lokCX/4x-Ultrasharp/resolve/main/4x-UltraSharp.pth

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ComfyUI successfully installed.%reset%

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


:run_comfyui
title ComfyUI
cls
echo %blue_fg_strong%/ Home / Run ComfyUI%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the sillytavernextras environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment comfyui...
call conda activate comfyui

REM Start ComfyUI clean
start cmd /k "title ComfyUI && cd /d %~dp0ComfyUI && python main.py --auto-launch --listen --port 7901"
goto :home


:update_comfyui
title ComfyUI [UPDATE]
cls
echo %blue_fg_strong%/ Home / Update%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating ComfyUI...
cd /d "%~dp0ComfyUI"

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
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ComfyUI updated successfully.%reset%
    )
)
pause
goto :home




REM Toolbox - Frontend
:toolbox
title ComfyUI [TOOLBOX]
cls
echo %blue_fg_strong%/ Home / Toolbox %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Workflows
echo 2. Uninstall ComfyUI
echo 3. Back to Home


set "toolbox_choice="
set /p "toolbox_choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM toolbox - Backend
if "%toolbox_choice%"=="1" (
    call :workflows
) else if "%toolbox_choice%"=="2" (
    call :uninstall_comfyui
) else if "%toolbox_choice%"=="3" (
    call :home
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :toolbox
)

:uninstall_comfyui
title ComfyUI [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of ComfyUI                                                 ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'comfyui'...
    call conda deactivate
    call conda remove --name comfyui --all -y
    call conda clean -a -y

    REM Remove the folder ComfyUI
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the ComfyUI directory...
    cd /d "%~dp0"
    rmdir /s /q ComfyUI

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ComfyUI uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)


REM Workflows - Frontend
:workflows
cd /d "%~dp0"
title ComfyUI [WORKFLOWS]
cls
echo %blue_fg_strong%/ Home / Toolbox / Workflows%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install gtm-sdxl-sd15
echo 2. Install hybrid-w-style-selector
echo 3. Back to Toolbox


set "workflows_choice="
set /p "workflows_choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM toolbox - Backend
if "%workflows_choice%"=="1" (
    call :workflow_pack01
) else if "%workflows_choice%"=="2" (
    call :workflow_pack02
) else if "%workflows_choice%"=="3" (
    call :toolbox
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :toolbox
)


:workflow_pack01
REM Clone extension requirements for GTM ComfyUI workflow
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning extensions for GTM ComfyUI Workflow...
cd /d "%~dp0ComfyUI\custom_nodes"
git clone https://github.com/chrisgoringe/cg-use-everywhere.git
git clone https://github.com/bash-j/mikey_nodes.git
git clone https://github.com/twri/sdxl_prompt_styler.git
git clone https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes.git
git clone https://github.com/BadCafeCode/masquerade-nodes-comfyui.git
git clone https://github.com/space-nuko/ComfyUI-OpenPose-Editor.git
git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
git clone https://github.com/RockOfFire/ComfyUI_Comfyroll_CustomNodes.git

mkdir "%~dp0comfyui-workflows"
start https://civitai.com/api/download/models/179750

REM Wait for the user to complete the download in the browser
for /l %%i in (10,-1,1) do (
    set /p "=Waiting for download to complete... Please wait %cyan_fg_strong%%%i%reset%" <nul
    timeout /t 1 >nul
    echo.
)


REM Move the file to the desired directory
move "%userprofile%\Downloads\gtmComfyuiWorkflows_cleanuiV11.zip" "%~dp0comfyui-workflows\gtmComfyuiWorkflows_cleanuiV11.zip"

REM Extract Mangio-RVC 7z archive
cd /d "%~dp0comfyui-workflows"
"%ProgramFiles%\7-Zip\7z.exe" x "gtmComfyuiWorkflows_cleanuiV11.zip" || (
    color 4
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Extraction failed.. Please try again%reset%
    pause
    goto :workflows
)

REM Cleanup downloaded zip
del "%~dp0comfyui-workflows\gtmComfyuiWorkflows_cleanuiV11.zip"
goto :workflows

:workflow_pack02
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning extensions for Hybrid w Style Selector...
cd /d "%~dp0ComfyUI\custom_nodes"
git clone https://github.com/twri/sdxl_prompt_styler.git
git clone https://github.com/LucianoCirino/efficiency-nodes-comfyui.git

mkdir "%~dp0comfyui-workflows"
start https://civitai.com/api/download/models/150004

REM Wait for the user to complete the download in the browser
for /l %%i in (10,-1,1) do (
    set /p "=Waiting for download to complete... Please wait %cyan_fg_strong%%%i%reset%" <nul
    timeout /t 1 >nul
    echo.
)

REM Move the file to the desired directory
move "%userprofile%\Downloads\comfyuiHybridWStyle_v10.zip" "%~dp0comfyui-workflows\comfyuiHybridWStyle_v10.zip"

REM Extract Mangio-RVC 7z archive
cd /d "%~dp0comfyui-workflows"
"%ProgramFiles%\7-Zip\7z.exe" x "comfyuiHybridWStyle_v10.zip" || (
    color 4
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Extraction failed.. Please try again%reset%
    pause
    goto :workflows
)

REM Cleanup downloaded zip
del "%~dp0comfyui-workflows\comfyuiHybridWStyle_v10.zip"
goto :workflows