@echo off
REM AudioCraft-Plus Launcher
REM Created by: Deffcolony
REM Github: https://github.com/GrandaddyShmax/audiocraft_plus
REM
REM Description:
REM This script can install AudioCraft-Plus
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title AudioCraft-Plus Launcher
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

REM Environment Variables (TOOLBOX FFmpeg)
set "ffmpeg_url=https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
set "ffdownload_path=%~dp0ffmpeg.7z"
set "ffextract_path=C:\ffmpeg"
set "bin_path=%ffextract_path%\bin"

REM Environment Variables (winget)
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"

REM Environment Variables (TOOLBOX Install Extras)
set "miniconda_path=%userprofile%\miniconda3"

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
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Git is installed. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Git is already installed.%reset%
)

REM Check if Miniconda3 is installed if not then install Miniconda3
call conda --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Miniconda3 is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda3 using Winget...
    winget install -e --id Anaconda.Miniconda3
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Miniconda3 installed successfully. Please restart the Installer.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Miniconda3 is already installed.%reset%
)

REM home Frontend
:home
title AudioCraft-Plus [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install AudioCraft-Plus
echo 2. Run AudioCraft-Plus
echo 3. Run AudioCraft-Plus + share
echo 4. Update
echo 5. Uninstall AudioCraft-Plus
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_audiocraft_plus
) else if "%choice%"=="2" (
    call :run_audiocraft_plus
) else if "%choice%"=="3" (
    call :run_audiocraft_plus_share
) else if "%choice%"=="4" (
    call :update_audiocraft_plus
) else if "%choice%"=="5" (
    call :uninstall_audiocraft_plus
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


:install_audiocraft_plus
title AudioCraft-Plus [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install AudioCraft-Plus%reset%
echo ---------------------------------------------------------------

REM GPU menu - Frontend
echo What is your GPU?
echo 1. NVIDIA
echo 2. AMD
echo 3. None (CPU-only mode)
echo 0. Cancel install

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

REM GPU menu - Backend
REM Set the GPU choice in an environment variable for choise callback
set "GPU_CHOICE=%gpu_choice%"

REM Check the user's response
if "%gpu_choice%"=="1" (
    REM Install pip requirements
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% GPU choice set to NVIDIA
    goto :install_audiocraft_plus_pre
) else if "%gpu_choice%"=="2" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% GPU choice set to AMD
    goto :install_audiocraft_plus_pre
) else if "%gpu_choice%"=="3" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Using CPU-only mode
    goto :install_audiocraft_plus_pre
) else if "%gpu_choice%"=="0" (
    goto :home
) else (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Invalid number. Please enter a valid number.%reset%
    pause
    goto :install_audiocraft_plus
)

:install_audiocraft_plus_pre
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing AudioCraft-Plus...

set max_retries=3
set retry_count=0

:retry_audiocraft_plus_pre
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning audiocraft_plus repository...
git clone https://github.com/GrandaddyShmax/audiocraft_plus.git

if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_audiocraft_plus_pre
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to clone repository after %max_retries% retries.%reset%
    pause
    goto :home
)


echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Checking for Miniconda3 update...
winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named audiocraftplus
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment audiocraftplus...
call conda create -n audiocraftplus -y

REM Activate the audiocraft environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment audiocraft...
call conda activate audiocraftplus

REM Install Python 3.9.13 and Git in the audiocraftplus environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Python 3.9.13 in conda env: audiocraftplus
call conda install python=3.9.13 -y

cd /d "%~dp0audiocraft_plus"

REM Use the GPU choice made earlier to set the correct PyTorch index-url
if "%GPU_CHOICE%"=="1" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing NVIDIA version of PyTorch for AudioCraft-Plus...
    pip install torch==2.1.0+cu121 torchvision torchaudio==2.1.0+cu121 --index-url https://download.pytorch.org/whl/cu121
    goto :install_audiocraft_plus_now
) else if "%GPU_CHOICE%"=="2" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing AMD version of PyTorch for AudioCraft-Plus...
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6
    goto :install_audiocraft_plus_now
) else if "%GPU_CHOICE%"=="3" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing CPU-only version of PyTorch for AudioCraft-Plus...
    pip install torch torchvision torchaudio
    goto :install_audiocraft_plus_now
)

:install_audiocraft_plus_now
REM Install pip requirements
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing pip requirements...
pip install -r requirements.txt
pip install ffmpeg
pip install pytaglib
pip install pydantic
pip install gradio
pip install gradio-client



echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%AudioCraft-Plus successfully installed.%reset%

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


:run_audiocraft_plus
title AudioCraft-Plus
cls
echo %blue_fg_strong%/ Home / Run AudioCraft-Plus%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the audiocraftplus environment
call conda activate audiocraftplus

REM Start audiocraftplus clean
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% AudioCraft-Plus launched in a new window.
start cmd /k "title AudioCraft-Plus && cd /d %~dp0audiocraft_plus && python app.py --inbrowser --server_port 7902"
goto :home


:run_audiocraft_plus_share
title AudioCraft-Plus [SHARE]
cls
echo %blue_fg_strong%/ Home / Run AudioCraft-Plus + share%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"
echo %blue_fg_strong%[INFO]%reset% Running AudioCraft-Plus + share...

REM Activate the audiocraftplus environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment audiocraftplus...
call conda activate audiocraftplus

cls
echo %blue_fg_strong%/ Home / AudioCraft-Plus + share%reset%
echo ---------------------------------------------------------------

REM Prompt user for username
set /p username=Enter a username: 

REM Prompt user for password creation
powershell -command "$password = Read-Host 'Enter a password' -AsSecureString; $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password); $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR); Write-Output $password" > temp_pass.txt
set /p password=<temp_pass.txt
del temp_pass.txt
REM --listen 7702
start cmd /k "title AudioCraft-Plus SHARE && cd /d %~dp0audiocraft_plus && python app.py --inbrowser --server_port 7702 --share --username %username% --password %password%"
goto :home


:update_audiocraft_plus
title AudioCraft-Plus [UPDATE]
REM Update audiocraft_plus
set max_retries=3
set retry_count=0

:retry_update_audiocraft_plus
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating audiocraft_plus...
cd /d "%~dp0audiocraft_plus"
call git pull
if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_update_audiocraft_plus
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to update audiocraft_plus repository after %max_retries% retries.%reset%
    pause
    goto :home
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%audiocraft_plus updated successfully.%reset%
pause
goto :home

:uninstall_audiocraft_plus
title AudioCraft-Plus [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of AudioCraft-Plus                                         ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'audiocraftplus'...
    call conda deactivate
    call conda remove --name audiocraftplus --all -y
    call conda clean -a -y

    REM Remove the folder audiocraft_plus
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the audiocraft_plus directory...
    cd /d "%~dp0"
    rmdir /s /q audiocraft_plus

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%AudioCraft-Plus uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)