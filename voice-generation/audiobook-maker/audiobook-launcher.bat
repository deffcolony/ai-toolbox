@echo off
REM Audiobook Maker Launcher
REM Created by: Deffcolony
REM Github: https://github.com/JarodMica/audiobook_maker
REM
REM Description:
REM This script can install Audiobook Maker
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title Audiobook Maker Launcher
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
set "green_bg=[42m"

set "audiobookmaker_install_path=%~dp0\audiobook_maker"
set "audiobookmaker_userdata_path=%~dp0userdata"
set "audiobookmaker_modules_tortoise_path=%audiobookmaker_install_path%\modules\tortoise_tts_api"

REM Environment Variables (winget)
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"

REM Environment Variables (miniconda3)
set "miniconda_download_url=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
set "miniconda_download_path=%audiobookmaker_userdata_path%\miniconda.exe"
set "miniconda_install_path=%audiobookmaker_userdata_path%\miniconda3"
set "miniconda_env_path=%audiobookmaker_userdata_path%\env"
set "miniconda_env_audiobookmaker_path=%miniconda_env_path%\audiobookmaker"
set "miniconda_path_mingw=%userprofile%\miniconda3\Library\mingw-w64\bin"
set "miniconda_path_usrbin=%userprofile%\miniconda3\Library\usr\bin"
set "miniconda_path_bin=%userprofile%\miniconda3\Library\bin"
set "miniconda_path_scripts=%userprofile%\miniconda3\Scripts"

REM Environment Variables (RVC)
set "fairseq_download_url=https://huggingface.co/Jmica/rvc/resolve/main/fairseq-0.12.4-cp311-cp311-win_amd64.whl"
set "fairseq_download_path=%audiobookmaker_userdata_path%\fairseq-0.12.4-cp311-cp311-win_amd64.whl"

REM Environment Variables (FFmpeg)
set "ffmpeg_download_url=https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
set "ffmpeg_download_path=%audiobookmaker_userdata_path%\ffmpeg.7z"
set "ffmpeg_install_path=C:\ffmpeg"
set "ffmpeg_path_bin=%ffmpeg_install_path%\bin"

REM Environment Variables (7-Zip)
set "zip7_version=7z2301-x64"
set "zip7_install_path=%ProgramFiles%\7-Zip"
set "zip7_download_path=%TEMP%\%zip7_version%.exe"

REM Define the paths and filenames for the shortcut creation
set "shortcutTarget=%~dp0audiobook-launcher.bat"
set "iconFile=%~dp0audiobook-maker.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=audiobook-launcher.lnk"
set "startIn=%~dp0"
set "comment=Audiobook Maker Launcher"

REM Define variables for logging
set "log_path=%audiobookmaker_userdata_path%\logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"

cd /d "%~dp0"

REM Check if the folder exists
if not exist "%audiobookmaker_userdata_path%" (
    mkdir "%audiobookmaker_userdata_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "userdata"  
)
REM Check if the folder exists
if not exist "%miniconda_install_path%" (
    mkdir "%miniconda_install_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "miniconda3"  
)
REM Check if the folder exists
if not exist "%miniconda_env_path%" (
    mkdir "%miniconda_env_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "env"  
)

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


REM ############################################################
REM ################## HOME - FRONTEND #########################
REM ############################################################
:home
title Audiobook Maker [HOME]
cls
echo %blue_fg_strong%^| ^> / Home                                                     ^|%reset%
echo %blue_fg_strong% ==============================================================%reset%   
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| What would you like to do?                                   ^|%reset%
echo    1. Start Audiobook Maker
echo    2. Installer
echo    3. Update
echo    4. Uninstall Audiobook Maker
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Menu Options:                                                ^|%reset%
echo    0. Exit
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^|                                                              ^|%reset%

:: Define a variable containing a single backspace character
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set "BS=%%A"

:: Set the prompt with spaces
set /p "home_choice=%BS%   Choose Your Destiny: "

REM Default to home_choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined home_choice set "home_choice=1"

REM home - Backend
if "%home_choice%"=="1" (
    call :start_audiobook_maker
) else if "%home_choice%"=="2" (
    call :abm_installer_menu
) else if "%home_choice%"=="3" (
    call :update_audiobook_maker
) else if "%home_choice%"=="4" (
    call :uninstall_audiobook_maker
) else if "%home_choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


REM ############################################################
REM ##### AUDIOBOOK MAKER INSTALLER - FRONTEND #################
REM ############################################################
:abm_installer_menu
title Audiobook Maker [INSTALLER]

cls
echo %blue_fg_strong%^| ^> / Home / Installer                                         ^|%reset%
echo %blue_fg_strong% ==============================================================%reset%
echo    1. Install Audiobook Maker
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Text-to-Speech Engines                                       ^|%reset%
echo    2. Install TortoiseTTS
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Speech-to-Speech Engines                                     ^|%reset%
echo    3. Install RVC
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Additional packages                                          ^|%reset%
echo    4. Install 7-Zip
echo    5. Install FFmpeg
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Menu Options:                                                ^|%reset%
echo    0. Back
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^|                                                              ^|%reset%

:: Define a variable containing a single backspace character
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set "BS=%%A"

:: Set the prompt with spaces
set /p "abm_installer_choice=%BS%   Choose Your Destiny: "

REM ######## APP INSTALLER IMAGE GENERATION - BACKEND #########
if "%abm_installer_choice%"=="1" (
    call :install_audiobook_maker
) else if "%abm_installer_choice%"=="2" (
    goto :install_tortoise_tts
) else if "%abm_installer_choice%"=="3" (
    goto :install_rvc
) else if "%abm_installer_choice%"=="4" (
    goto :install_7zip
) else if "%abm_installer_choice%"=="5" (
    goto :install_ffmpeg
) else if "%abm_installer_choice%"=="0" (
    goto :home
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :abm_installer_menu
)


:install_audiobook_maker
title Audiobook Maker [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install Audiobook Maker%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Audiobook Maker...
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

REM deactivate existing conda envs
(call conda deactivate && call conda deactivate && call conda deactivate) 2>nul

REM This is used when the audiobook-launcher.bat is outside the audiobook_maker folder uncomment all to auto clone for portable install
set max_retries=3
set retry_count=0
:retry_install_audiobook_maker
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning the Audiobook Maker repository...
git clone https://github.com/JarodMica/audiobook_maker.git
if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_install_audiobook_maker
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to clone repository after %max_retries% retries.%reset%
    pause
    goto :home
)
cd /d "%audiobookmaker_install_path%"

echo %blue_fg_strong%[INFO]%reset% Installing 7-Zip...
winget install -e --id 7zip.7zip

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

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-zip added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] 7-Zip already exists in PATH.%reset%
)

rem Update the PATH value for the current session
REM set PATH=%new_path%

rem Check if 7z correctly was installed
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] App command: "7z" from app: "7-Zip" NOT FOUND. The app is not installed or added to PATH.
) else (
    echo [ %green_fg_strong%OK%reset% ] Found app command: %cyan_fg_strong%"7z"%reset% from app: "7-Zip"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-Zip installed successfully.%reset%
)

rmdir /s /q "%ffmpeg_install_path%"

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

rem Update the PATH value for the current session
REM set PATH=%new_path%

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading Miniconda...
curl -L -o "%miniconda_download_path%" "%miniconda_download_url%" 

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda...
start /wait "" "%miniconda_download_path%" /InstallationType=JustMe /NoShortcuts=1 /AddToPath=0 /RegisterPython=0 /NoRegistry=1 /S /D=%miniconda_install_path%
del "%miniconda_download_path%"

REM Create a Conda environment named audiobookmaker
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment: %cyan_fg_strong%audiobookmaker%reset%
call "%miniconda_install_path%\_conda.exe" create -k --no-shortcuts --prefix "%miniconda_env_audiobookmaker_path%" python=3.11 git -y

REM check if conda environment was actually created
if not exist "%miniconda_env_audiobookmaker_path%\python.exe" ( echo. && echo Conda environment is empty. && goto end )

REM environment isolation
set PYTHONNOUSERSITE=1
set PYTHONPATH=
set PYTHONHOME=
set "CUDA_PATH=%miniconda_env_audiobookmaker_path%"
set "CUDA_HOME=%CUDA_PATH%"

REM Activate the environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment %cyan_fg_strong%audiobookmaker%reset%
call "%miniconda_install_path%\condabin\conda.bat" activate "%miniconda_env_audiobookmaker_path%" || ( echo. && echo Miniconda hook not found. && goto end )

cd /d "%audiobookmaker_install_path%"

REM Install pip requirements in the activated environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing pip requirements
pip install -r requirements.txt

REM Initialize and update git submodules
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Initializing and updating git submodules
git submodule init
git submodule update --remote

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Audiobook Maker successfully installed.%reset%

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
goto :abm_installer_menu



:install_tortoise_tts
REM Activate the audiobookmaker environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment: %cyan_fg_strong%audiobookmaker%reset%
call "%miniconda_install_path%\condabin\conda.bat" activate "%miniconda_env_audiobookmaker_path%" || ( echo. && echo Miniconda hook not found. && goto end )
cd /d "%audiobookmaker_modules_tortoise_path%"

REM Initialize and update git submodules
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Initializing and updating git submodules
git submodule init
git submodule update --remote

REM Install pip requirements
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing pip requirements
pip install modules\tortoise_tts
pip install modules\dlas
pip install .

cd /d "%audiobookmaker_install_path%"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstalling Torch...
pip uninstall torch -y
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installingen Torch...
pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cu121
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%TortoiseTTS successfully installed.%reset%
pause
goto :abm_installer_menu


:install_rvc
REM Activate the audiobookmaker environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment: %cyan_fg_strong%audiobookmaker%reset%
call "%miniconda_install_path%\condabin\conda.bat" activate "%miniconda_env_audiobookmaker_path%" || ( echo. && echo Miniconda hook not found. && goto end )

REM Install pip requirements
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing pip requirements
cd /d "%audiobookmaker_userdata_path%"
curl -L -o "%fairseq_download_path%" "%fairseq_download_url%" 
pip install .\fairseq-0.12.4-cp311-cp311-win_amd64.whl
pip install git+https://github.com/JarodMica/rvc-python
pip show torch

REM Cleanup the downloaded file
del "%fairseq_download_path%"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%RVC successfully installed.%reset%
pause
goto :abm_installer_menu


:install_7zip
title Audiobook Maker [INSTALL-7Z]
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing 7-Zip...
winget install -e --id 7zip.7zip

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

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-zip added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] 7-Zip already exists in PATH.%reset%
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-Zip installed successfully. Please restart the launcher to activate 7z command%reset%
pause
goto :abm_installer_menu


:install_ffmpeg
title Audiobook Maker [INSTALL-FFMPEG]
REM Check if 7-Zip is installed
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] 7z command not found in PATH.%reset%
    echo %red_fg_strong%7-Zip is not installed or not found in the system PATH.%reset%
    echo %red_fg_strong%To install 7-Zip go to:%reset% %blue_bg%/ Home / Installer / Install 7-Zip%reset%
    pause
    goto :abm_installer_menu
)

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

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ffmpeg added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] ffmpeg already exists in PATH.%reset%
)
del "%ffmpeg_download_path%"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ffmpeg installed successfully. Please restart the launcher to activate ffmpeg command%reset%
pause
goto :abm_installer_menu


:start_audiobook_maker
title Audiobook Maker
REM Check if the folder exists
if not exist "%audiobookmaker_install_path%" (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Audiobook Maker is not installed. Please install it first.%reset%
    pause
    goto :home
)

cls
echo %blue_fg_strong%/ Home / Start Audiobook Maker%reset%
echo ---------------------------------------------------------------

REM Activate the audiobookmaker environment
call "%miniconda_install_path%\condabin\conda.bat" activate "%miniconda_env_audiobookmaker_path%" || ( echo. && echo Miniconda hook not found. && goto end )

REM Start Audiobook Maker
start cmd /k "title Audiobook Maker && cd /d %audiobookmaker_install_path% && python src\controller.py"
goto :home


:update_audiobook_maker
title Audiobook Maker [UPDATE]
cls
echo %blue_fg_strong%/ Home / Update%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating Audiobook Maker...
cd /d "%audiobookmaker_install_path%"

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
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Audiobook Maker updated successfully.%reset%
    )
)
pause
goto :home

:uninstall_audiobook_maker
title Audiobook Maker [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of Audiobook Maker                                         ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Deactivating any active Conda environment...
    call "%miniconda_install_path%\condabin\conda.bat" deactivate
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cleaning up Conda package cache and temporary files...
    call "%miniconda_install_path%\_conda.exe" clean -a -y

    REM Remove the folder audiobook_maker
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the audiobook_maker directory...
    rmdir /s /q "%audiobookmaker_install_path%"

    REM Remove the folder userdata
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing userdata directory: %cyan_fg_strong%%audiobookmaker_userdata_path%%reset%
    rmdir /s /q "%audiobookmaker_userdata_path%"



    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Audiobook Maker uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)