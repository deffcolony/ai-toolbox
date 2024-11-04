@echo off
REM VoiceCraft Launcher
REM Created by: Deffcolony
REM Github: https://github.com/jasonppy/VoiceCraft
REM
REM Description:
REM This script can install VoiceCraft
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title VoiceCraft Launcher
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

REM Environment Variables (miniconda3)
set "miniconda_path=%userprofile%\miniconda3"

REM Define variables for install locations
set "voicecraft_install_path=%~dp0VoiceCraft"

REM Environment Variables (7-Zip)
set "zip7_version=7z2301-x64"
set "zip7_install_path=%ProgramFiles%\7-Zip"
set "zip7_download_path=%TEMP%\%zip7_version%.exe"

REM Environment Variables (eSpeak)
set "espeak_download_url=https://downloads.sourceforge.net/project/espeak/espeak/espeak-1.48/setup_espeak-1.48.04.exe"
set "espeak_download_path=%~dp0setup_espeak-1.48.04.exe"
set "espeak_install_path=%ProgramFiles(x86)%\eSpeak"
set "espeak_path_commandline=%espeak_install_path%\command_line"

REM Environment Variables (FFmpeg)
set "ffmpeg_download_url=https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
set "ffmpeg_download_path=%~dp0ffmpeg.7z"
set "ffmpeg_install_path=C:\ffmpeg"
set "ffmpeg_path_bin=%ffmpeg_install_path%\bin"


REM Define the paths and filenames for the shortcut creation
set "shortcutTarget=%~dp0voicecraft-launcher.bat"
set "iconFile=%~dp0voicecraft.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=voicecraft-launcher.lnk"
set "startIn=%~dp0"
set "comment=VoiceCraft Launcher"

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


REM home Frontend
:home
title VoiceCraft [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install VoiceCraft
echo 2. Start VoiceCraft
echo 3. Update
echo 4. Uninstall VoiceCraft
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_voicecraft
) else if "%choice%"=="2" (
    call :start_voicecraft
) else if "%choice%"=="3" (
    call :update_voicecraft
) else if "%choice%"=="4" (
    call :uninstall_voicecraft
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


:install_voicecraft
title VoiceCraft [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install VoiceCraft%reset%
echo ---------------------------------------------------------------
REM GPU menu - Frontend
echo What is your GPU?
echo 1. NVIDIA
echo 2. AMD
echo 0. Cancel

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
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% GPU choice set to NVIDIA
    goto :install_voicecraft_pre
) else if "%gpu_choice%"=="2" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% GPU choice set to AMD
    goto :install_voicecraft_pre
) else if "%gpu_choice%"=="0" (
    goto :home
) else (
    echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :install_voicecraft
)
:install_voicecraft_pre
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing VoiceCraft...

set max_retries=3
set retry_count=0
:retry_install_voicecraft
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning the VoiceCraft repository...
git clone https://github.com/jasonppy/VoiceCraft.git

if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_install_voicecraft
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to clone repository after %max_retries% retries.%reset%
    pause
    goto :home
)
cd /d "%voicecraft_install_path%"


REM Update the PATH value to activate the command for the current session
set PATH=%PATH%;%zip7_install_path%;%ffmpeg_path_bin%;%espeak_path_commandline%

REM Check if 7-Zip is installed
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] 7z command not found in PATH.%reset%
    echo %red_fg_strong%7-Zip is not installed or not found in the system PATH.%reset%
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



rem Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

rem Check if the paths are already in the current PATH
echo %current_path% | find /i "%ffmpeg_path_bin%" > nul
set "ff_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %ff_path_exists% neq 0 (
    set "new_path=%current_path%;%ffmpeg_path_bin%"
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "ffmpeg_path_bin is:%cyan_fg_strong% %ffmpeg_path_bin%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value to activate the command on system level
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ffmpeg added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] ffmpeg already exists in PATH.%reset%
)


REM Check if ffmpeg is installed
if not exist "%ffmpeg_install_path%" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading FFmpeg archive...
    curl -L -o "%ffmpeg_download_path%" "%ffmpeg_download_url%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating ffmpeg directory if it doesn't exist...
    if not exist "%ffmpeg_install_path%" (
        mkdir "%ffmpeg_install_path%"
    )

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Extracting FFmpeg archive...
    7z x "%ffmpeg_download_path%" -o"%ffmpeg_install_path%"


    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Moving FFmpeg contents to C:\ffmpeg...
    for /d %%i in ("%ffmpeg_install_path%\ffmpeg-*-full_build") do (
        xcopy "%%i\bin" "%ffmpeg_install_path%\bin" /E /I /Y
        xcopy "%%i\doc" "%ffmpeg_install_path%\doc" /E /I /Y
        xcopy "%%i\presets" "%ffmpeg_install_path%\presets" /E /I /Y
        rd "%%i" /S /Q
    )
    del "%ffmpeg_download_path%"
)


rem Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

rem Check if the paths are already in the current PATH
echo %current_path% | find /i "%espeak_path_commandline%" > nul
set "espeak_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %espeak_path_exists% neq 0 (
    set "new_path=%current_path%;%espeak_path_commandline%"
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "espeak_path_commandline is:%cyan_fg_strong% %espeak_path_commandline%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value to activate the command on system level
    setx PATH "!new_path!" > nul

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%eSpeak added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] eSpeak already exists in PATH.%reset%
)


REM Check if eSpeak is installed
if not exist "%espeak_install_path%" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing eSpeak...
    winget install -e --id espeak.espeak
)


echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda...
winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named voicecraft
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment voicecraft...
call conda create -n voicecraft python=3.9.16 -y

REM Activate the voicecraft environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment voicecraft...
call conda activate voicecraft

REM Use the GPU choice made earlier to install requirements for voicecraft
if "%GPU_CHOICE%"=="1" (
    echo %blue_bg%[%time%]%reset% %cyan_fg_strong%[voicecraft]%reset% %blue_fg_strong%[INFO]%reset% Installing NVIDIA version from requirements.txt in conda enviroment: %cyan_fg_strong%voicecraft%reset%
REM    pip install -r requirements.txt
    pip install torch==2.2.0+cu121 torchaudio==2.2.0+cu121 --upgrade --force-reinstall --extra-index-url https://download.pytorch.org/whl/cu121
    goto :install_voicecraft_final
) else if "%GPU_CHOICE%"=="2" (
    echo %blue_bg%[%time%]%reset% %cyan_fg_strong%[voicecraft]%reset% %blue_fg_strong%[INFO]%reset% Installing AMD version from requirements-amd.txt in conda enviroment: %cyan_fg_strong%voicecraft%reset%
REM    pip install -r requirements-amd.txt
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6
    goto :install_voicecraft_final
)
:install_voicecraft_final

echo %blue_bg%[%time%]%reset% %cyan_fg_strong%[voicecraft]%reset% %blue_fg_strong%[INFO]%reset% Installing pip modules in conda enviroment: %cyan_fg_strong%voicecraft%reset%
pip install -e git+https://github.com/facebookresearch/audiocraft.git@c5157b5bf14bf83449c17ea1eeb66c19fb4bc7f0#egg=audiocraft
REM pip install xformers==0.0.22 [This downgrades torch to a lower version which means you cannot use torch==2.2.0+cu121 and torchaudio==2.2.0+cu121]
pip install tensorboard==2.16.2
pip install phonemizer==3.2.1
pip install datasets==2.16.0
pip install torchmetrics==0.11.1
REM pip install huggingface_hub==0.22.2 [transformers 4.41.0 requires huggingface-hub<1.0,>=0.23.0]
REM pip install espeakng
call conda install -c conda-forge montreal-forced-aligner=2.2.17 openfst=1.8.2 kaldi=5.5.1068 -y
mfa model download dictionary english_us_arpa
mfa model download acoustic english_us_arpa
call conda install -n voicecraft ipykernel --no-deps --force-reinstall -y
pip install -r gradio_requirements.txt
pip install nltk>=3.8.1
pip install openai-whisper>=20231117
pip install aeneas>=1.7.3.0
pip install whisperx>=3.1.1
pip install num2words==0.5.13

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%VoiceCraft successfully installed.%reset%

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


:start_voicecraft
title VoiceCraft
cls
echo %blue_fg_strong%/ Home / Start VoiceCraft%reset%
echo ---------------------------------------------------------------

REM Check if the folder exists
if not exist "%voicecraft_install_path%" (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Directory:%reset% %red_bg%VoiceCraft%reset% %red_fg_strong%not found.%reset%
    echo %red_fg_strong%Please install VoiceCraft first%reset%
    pause
    goto :home
)

REM Activate the voicecraft environment
call conda activate voicecraft

REM Start voicecraft clean
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% VoiceCraft launched in a new window.
start cmd /k "title VoiceCraft && cd /d %voicecraft_install_path% && python gradio_app.py"
goto :home


:update_voicecraft
REM Check if VoiceCraft directory exists
if not exist "%voicecraft_install_path%" (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] VoiceCraft directory not found. Skipping update.%reset%
    pause
    goto :home
)

REM Update VoiceCraft
set max_retries=3
set retry_count=0

:retry_update_voicecraft
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating VoiceCraft...
cd /d "%voicecraft_install_path%"
call git pull
if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_update_voicecraft
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to update VoiceCraft repository after %max_retries% retries.%reset%
    pause
    goto :home
)
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%VoiceCraft updated successfully.%reset%
pause
goto :home


:uninstall_voicecraft
title VoiceCraft [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of VoiceCraft                                              ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'voicecraft'...
    call conda deactivate
    call conda remove --name voicecraft --all -y
    call conda clean -a -y

    REM Remove the folder VoiceCraft
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the VoiceCraft directory...
    cd /d "%~dp0"
    rmdir /s /q "%voicecraft_install_path%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstalling eSpeak...
    winget uninstall --id espeak.espeak

    setlocal EnableDelayedExpansion
    rem Get the current PATH value from the registry
    for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

    rem Remove the path from the current PATH if it exists
    set "new_path=!current_path:%espeak_path_commandline%=!"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%eSpeak removed from PATH.%reset%
    endlocal

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%VoiceCraft uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)

