@echo off
REM Text generation web UI Launcher
REM Created by: Deffcolony
REM Github: https://github.com/oobabooga/text-generation-webui
REM
REM Description:
REM This script can install Text generation web UI
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
set "miniconda_path=%userprofile%\miniconda"

REM Define the paths and filenames for the shortcut creation
set "shortcutTarget=%~dp0textgen-launcher.bat"
REM set "iconFile=%SystemRoot%\System32\SHELL32.dll,153"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=textgen-Launcher.lnk"
set "startIn=%~dp0"
set "comment=textgen Launcher"


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
    curl -L -o "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "https://github.com/microsoft/winget-cli/releases/download/v1.6.2771/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    start "" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Winget installed successfully. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Winget is already installed.%reset%
)


REM home Frontend
:home
title textgen [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install textgen
echo 2. Run textgen
echo 3. Run textgen + addons
echo 4. Run textgen + share
echo 5. Update
echo 6. Uninstall textgen
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_textgen
) else if "%choice%"=="2" (
    call :run_textgen
) else if "%choice%"=="3" (
    call :run_textgen_addons
) else if "%choice%"=="4" (
    call :run_textgen_share
) else if "%choice%"=="5" (
    call :update_textgen
) else if "%choice%"=="6" (
    call :uninstall_textgen
) else if "%choice%"=="0" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:install_textgen
title textgen [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install textgen%reset%
echo ---------------------------------------------------------------
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

echo %blue_fg_strong%[INFO]%reset% Installing textgen...
git clone https://github.com/oobabooga/text-generation-webui.git

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda...
winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named textgen
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment textgen...
call conda create -n textgen -y 

REM Activate the textgen environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment textgen...
call conda activate textgen

REM Install Python in the textgen environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Python in the Conda environment...
call conda install python=3.10 -y

cd /d "%~dp0text-generation-webui/extensions/openai"

REM Install openai + xformers
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing openai extension and xformers...
pip install -r requirements.txt
pip install xformers
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%textgen Installed Successfully.%reset%

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


:configuretextgen
title textgen [CONFIGURE]
cls
echo %blue_fg_strong%/ Home / Configure textgen%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Running textgen...

REM Activate the textgen environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment textgen...
call conda activate textgen

cls
echo %blue_fg_strong%/ Home / Configure textgen%reset%
echo ---------------------------------------------------------------

echo COMMING SOON
pause
goto :home


:run_textgen
title textgen
cls
echo %blue_fg_strong%/ Home / Run textgen%reset%
echo ---------------------------------------------------------------

cd /d "%~dp0text-generation-webui"

REM config for portable miniconda
set INSTALL_DIR=%cd%\installer_files
set CONDA_ROOT_PREFIX=%cd%\installer_files\conda
set INSTALL_ENV_DIR=%cd%\installer_files\env

REM environment isolation for portable miniconda
set PYTHONNOUSERSITE=1
set PYTHONPATH=
set PYTHONHOME=
set "CUDA_PATH=%INSTALL_ENV_DIR%"
set "CUDA_HOME=%CUDA_PATH%"

REM check if conda environment even exists
if not exist "%INSTALL_ENV_DIR%\python.exe" ( echo. && echo Conda environment is empty. && pause )

REM activate portable miniconda env
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%"
pip install xformers
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" deactivate "%INSTALL_ENV_DIR%"


REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the textgen environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment textgen...
call conda activate textgen

REM Start textgen with desired configurations
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% textgen launched in a new window.
cd /d "%~dp0text-generation-webui"
start cmd /k start_windows.bat --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --xformers
goto :home


:run_textgen_addons
title textgen [ADDONS]
cls
echo %blue_fg_strong%/ Home / Run textgen + addons%reset%
echo ---------------------------------------------------------------
cd /d "%~dp0text-generation-webui"

REM config for portable miniconda
set INSTALL_DIR=%cd%\installer_files
set CONDA_ROOT_PREFIX=%cd%\installer_files\conda
set INSTALL_ENV_DIR=%cd%\installer_files\env

REM environment isolation for portable miniconda
set PYTHONNOUSERSITE=1
set PYTHONPATH=
set PYTHONHOME=
set "CUDA_PATH=%INSTALL_ENV_DIR%"
set "CUDA_HOME=%CUDA_PATH%"

REM check if conda environment even exists
if not exist "%INSTALL_ENV_DIR%\python.exe" ( echo. && echo Conda environment is empty. && pause )

REM activate portable miniconda env
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%"
pip install xformers
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" deactivate "%INSTALL_ENV_DIR%"


REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the textgen environment
call conda activate textgen

REM Start textgen with desired configurations
echo %blue_fg_strong%[INFO]%reset% textgen has been launched.
cd /d "%~dp0text-generation-webui"
start cmd /k start_windows.bat --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --model TheBloke_MythoMax-L2-13B-GPTQ --xformers
REM start cmd /k start_windows.bat --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --model TheBloke_MythoMax-L2-13B-GPTQ --xformers
REM You can add more flags like this --extensions openai --listen --listen-port 7910
goto :home


:run_textgen_share
title textgen [SHARE]
cls
echo %blue_fg_strong%/ Home / Run textgen + share%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"
echo %blue_fg_strong%[INFO]%reset% Running textgen + share...

REM Activate the textgen environment
call conda activate textgen

cls
echo %blue_fg_strong%/ Home / Run textgen + share%reset%
echo ---------------------------------------------------------------

REM Prompt user for username
set /p username=Enter a username: 

REM Prompt user for password creation
powershell -command "$password = Read-Host 'Enter a password' -AsSecureString; $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password); $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR); Write-Output $password" > temp_pass.txt
set /p password=<temp_pass.txt
del temp_pass.txt
cd /d "%~dp0text-generation-webui"
start cmd /k python one_click.py --gradio-auth %username%:%password% --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --model TheBloke_MythoMax-L2-13B-GPTQ --share
REM start cmd /k start_windows.bat --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --model TheBloke_MythoMax-L2-13B-GPTQ
REM You can add more flags like this --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --model TheBloke_MythoMax-L2-13B-GPTQ --share --xformers
goto :home


:update_textgen
title textgen [UPDATE]
cls
echo %blue_fg_strong%/ Home / Update%reset%
echo ---------------------------------------------------------------
echo Updating...
cd /d "%~dp0text-generation-webui"
REM Check if git is installed
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_fg_strong%[ERROR] git command not found in PATH. Skipping update.%reset%
    echo %red_bg%Please make sure Git is installed and added to your PATH.%reset%
    echo %blue_bg%To install Git go to Toolbox%reset%
) else (
    call git pull --rebase --autostash
    if %errorlevel% neq 0 (
        REM incase there is still something wrong
        echo There were errors while updating. Please download the latest version manually.
    )
)

REM config for portable miniconda
set INSTALL_DIR=%cd%\installer_files
set CONDA_ROOT_PREFIX=%cd%\installer_files\conda
set INSTALL_ENV_DIR=%cd%\installer_files\env

REM environment isolation for portable miniconda
set PYTHONNOUSERSITE=1
set PYTHONPATH=
set PYTHONHOME=
set "CUDA_PATH=%INSTALL_ENV_DIR%"
set "CUDA_HOME=%CUDA_PATH%"

REM check if conda environment was actually created
if not exist "%INSTALL_ENV_DIR%\python.exe" ( echo. && echo Conda environment is empty. && pause )

REM activate installer env
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%"
pip install --upgrade xformers
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" deactivate "%INSTALL_ENV_DIR%"
pause
goto :home


:uninstall_textgen
title textgen [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all Text generation web UI data                                     ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'textgen'...
    call conda remove --name textgen --all -y

    REM Remove the folder stable-diffusion-webui
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the text-generation-webui directory...
    cd /d "%~dp0"
    rmdir /s /q text-generation-webui

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Text generation web UI uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)