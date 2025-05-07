@echo off
REM Dia Launcher
REM Created by: Deffcolony
REM Github: https://github.com/nari-labs/dia
REM
REM Description:
REM This script can install dia
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title dia Launcher
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
set "shortcutTarget=%~dp0dia-launcher.bat"
REM set "iconFile=%SystemRoot%\System32\SHELL32.dll,153"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=dia-Launcher.lnk"
set "startIn=%~dp0"
set "comment=dia Launcher"

REM Define variables for logging
set "log_path=%~dp0logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"


REM Define variables for dia paths
set "dia_install_path=%~dp0dia"

setlocal enabledelayedexpansion

REM Check if Winget is installed; if not, then prompt the user to install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Winget is not installed on this system.%reset%
    set /p install_winget_choice="Install Winget? [Y/n]: "
    if /i "%install_winget_choice%"=="" set install_winget_choice=Y
    if /i "%install_winget_choice%"=="Y" (

        REM Ensure the bin directory exists
        if not exist "%bin_dir%" (
            mkdir "%bin_dir%"
            echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "bin"
        )

        REM Download the Winget installer into the bin directory
        powershell -Command "Invoke-RestMethod -Uri 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' -OutFile '%bin_dir%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'"

        REM Install Winget
        start /wait "%bin_dir%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

        REM Clean up the installer
        del "%bin_dir%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

        REM Get the current PATH value from the registry
        for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

        REM Check if the winget path is already in the current PATH
        echo %current_path% | find /i "%winget_path%" > nul
        if %errorlevel% neq 0 (
            set "new_path=%current_path%;%winget_path%"
            echo.
            echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
            echo.
            echo [DEBUG] "winget_path is:%cyan_fg_strong% %winget_path%%reset%"
            echo.
            echo [DEBUG] "new_path is:%cyan_fg_strong% %new_path%%reset%"

            REM Update the PATH value in the registry
            reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "%new_path%" /f

            REM Update the PATH value for the current session
            setx PATH "%new_path%" > nul
            echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Winget added to PATH.%reset%
        ) else (
            echo [ %green_fg_strong%OK%reset% ] Found PATH: winget%reset%
        )

        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Winget installed successfully. Please restart the Installer.%reset%
        pause
        exit
    ) else (
        echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Winget installation skipped by user.%reset%
    )
) else (
    echo [ %green_fg_strong%OK%reset% ] Found app command: %cyan_fg_strong%winget%reset% from app: App Installer
)

REM Check if Git is installed; if not, then install Git with fallback of powershell
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Git is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Git using winget...
    winget install -e --id Git.Git

    if %errorlevel% neq 0 (
        echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] winget failed to install Git or is not installed.%reset%

        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading Git using powershell...
        powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe', '%bin_dir%\git.exe')"

        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing git...
        start /wait %bin_dir%\git.exe /VERYSILENT /NORESTART
        
        del %bin_dir%\git.exe
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Git installed successfully.%reset%
    ) else (
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Git installed successfully.%reset%
    )
) else (
    echo [ %green_fg_strong%OK%reset% ] Found app command: %cyan_fg_strong%git%reset% from app: Git
)

REM home Frontend
:home
title dia [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install dia
echo 2. Configure dia
echo 3. Run dia
echo 4. Update
echo 5. Uninstall dia
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_dia
) else if "%choice%"=="2" (
    call :configure_dia
) else if "%choice%"=="3" (
    call :run_dia
) else if "%choice%"=="4" (
    call :update_dia
) else if "%choice%"=="5" (
    call :uninstall_dia
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


:install_dia
title dia [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install dia%reset%
echo ---------------------------------------------------------------
REM GPU menu - Frontend
echo What is your GPU?
echo 1. NVIDIA
echo 2. AMD
echo 0. Cancel

setlocal enabledelayedexpansion
chcp 65001 > nul
REM Get GPU information
set "gpu_info="
for /f "tokens=*" %%i in ('powershell -Command "Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name -First 1"') do (
    set "gpu_info=%%i"
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
    goto :install_dia_pre
) else if "%gpu_choice%"=="2" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% GPU choice set to AMD
    goto :install_dia_pre
) else if "%gpu_choice%"=="0" (
    goto :home
) else (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%
    pause
    goto :install_dia
)
:install_dia_pre
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing AllTalk...


REM Clone repository
set max_retries=3
set retry_count=0

:retry_install_dia
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cloning dia_tts repository...
git clone https://github.com/nari-labs/dia.git

if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_install_dia
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to clone repository after %max_retries% retries.%reset%
    pause
    goto :home
)
cd /d "%dia_install_path%"


REM Activate Miniconda and create environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment: %cyan_fg_strong%dia%reset%
call conda create -n dia python=3.10 -y
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment: %cyan_fg_strong%dia%reset%
call conda activate dia

REM Install dependencies
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Python dependencies...
pip install -e .

REM Use the GPU choice made earlier to install requirements for dia
if "%GPU_CHOICE%"=="1" (
    echo %blue_bg%[%time%]%reset% %cyan_fg_strong%[dia]%reset% %blue_fg_strong%[INFO]%reset% Installing NVIDIA version of PyTorch in conda environment: %cyan_fg_strong%dia%reset%
    pip install torch==2.6.0+cu126 torchaudio==2.6.0+cu126 --upgrade --force-reinstall --extra-index-url https://download.pytorch.org/whl/cu126
) else if "%GPU_CHOICE%"=="2" (
    echo %blue_bg%[%time%]%reset% %cyan_fg_strong%[dia]%reset% %blue_fg_strong%[INFO]%reset% Installing AMD dependencies...
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6
)
:install_dia_final


echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%dia Installed Successfully.%reset%

REM Ask if the user wants to create a shortcut
set /p create_shortcut=Do you want to create a shortcut on the desktop? [Y/n] 
if /i "%create_shortcut%"=="Y" (
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


:configure_dia
title dia [CONFIGURE]
cls
echo %blue_fg_strong%/ Home / Configure dia%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the dia environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment dia...
call conda activate dia

cls
echo %blue_fg_strong%/ Home / Configure dia%reset%
echo ---------------------------------------------------------------

echo COMMING SOON
pause
goto :home


:run_dia
title dia
cls
echo %blue_fg_strong%/ Home / Run dia%reset%
echo ---------------------------------------------------------------
echo %blue_fg_strong%[INFO]%reset% dia has been launched.

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the dia environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment dia...
call conda activate dia

REM Start dia
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% ChatDev launched in a new window.
start cmd /k "title dia && cd /d %dia_install_path% && python app.py"
goto :home


:update_dia
title dia [UPDATE]
cls
echo %blue_fg_strong%/ Home / Update%reset%
echo ---------------------------------------------------------------


REM Check if dia directory exists
if not exist "%dia_install_path%" (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] dia directory not found. Skipping update.%reset%
    pause
    goto :home
)

REM Update dia
set max_retries=3
set retry_count=0

:retry_update_dia
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating dia...
cd /d "%dia_install_path%"
call git pull
if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_update_dia
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to update dia repository after %max_retries% retries.%reset%
    pause
    goto :home
)
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%dia updated successfully.%reset%
pause
goto :home


:uninstall_dia
title dia [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of dia                                                     ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'dia'...
    call conda deactivate
    call conda remove --name dia --all -y
    call conda clean -a -y

    REM Remove the folder dia
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the dia directory...
    cd /d "%~dp0"
    rmdir /s /q "%dia_install_path%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%dia uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)