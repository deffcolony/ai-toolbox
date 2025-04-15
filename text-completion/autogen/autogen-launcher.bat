@echo off
REM AutoGen Launcher
REM Created by: Deffcolony
REM Github: https://github.com/microsoft/autogen
REM
REM Description:
REM This script can install autogen
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title AutoGen Launcher
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
set "shortcutTarget=%~dp0autogen-launcher.bat"
REM set "iconFile=%SystemRoot%\System32\SHELL32.dll,153"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=AutoGen-Launcher.lnk"
set "startIn=%~dp0"
set "comment=AutoGen Launcher"

REM Define variables for logging
set "log_path=%~dp0logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"


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


REM home Frontend
:home
title autogen [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install autogen
echo 2. Configure autogen
echo 3. Run autogen
echo 4. Update
echo 5. Uninstall autogen
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_autogen
) else if "%choice%"=="2" (
    call :configure_autogen
) else if "%choice%"=="3" (
    call :run_autogen
) else if "%choice%"=="4" (
    call :update_autogen
) else if "%choice%"=="5" (
    call :uninstall_autogen
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


:install_autogen
title autogen [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install autogen%reset%
echo ---------------------------------------------------------------
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing autogen...

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda...
winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named autogen
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating Conda environment autogen...
call conda create -n autogen python=3.11.4 git -y 

REM Activate the autogen environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment autogen...
call conda activate autogen

REM Install dependencies
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Python dependencies...
pip install autogen-agentchat autogen-ext[openai] python-dotenv elevenlabs requests

REM Create & Navigate to the bin directory
mkdir bin && cd bin

REM Copy app.py template to bin folder
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Copying app.py template to bin folder...
copy "%~dp0templates\app.py" "%~dp0bin\app.py" >nul 2>&1
if %errorlevel% equ 0 (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%app.py copied successfully to bin folder.%reset%
) else (
    echo %yellow_fg_strong%[WARN]%reset% Could not find templates\app.py. Please place an app.py template in the bin folder manually to use it.
)

REM Copy .env.example to .env in bin folder
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Copying .env.example to .env in bin folder...
copy "%~dp0templates\.env.example" "%~dp0bin\.env" >nul 2>&1
if %errorlevel% equ 0 (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%.env copied successfully to bin folder.%reset%
    echo %yellow_fg_strong%[NOTE]%reset% Please edit bin\.env to add your OpenAI, ElevenLabs, and Stability AI API keys.
) else (
    echo %yellow_fg_strong%[WARN]%reset% Could not find templates\.env.example. Please create a .env file in the bin folder with OPENAI_API_KEY, ELEVENLABS_API_KEY, and STABILITY_API_KEY.
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%autogen Installed Successfully.%reset%

echo %yellow_fg_strong%[NOTE]%reset% To use a template (e.g., app-template2.py), rename it to 'app.py' and move it into the 'bin' folder created in this directory.

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


:configure_autogen
title autogen [CONFIGURE]
cls
echo %blue_fg_strong%/ Home / Configure autogen%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the autogen environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment autogen...
call conda activate autogen

cls
echo %blue_fg_strong%/ Home / Configure autogen%reset%
echo ---------------------------------------------------------------

echo COMMING SOON
pause
goto :home


:run_autogen
title autogen
cls
echo %blue_fg_strong%/ Home / Run autogen%reset%
echo ---------------------------------------------------------------
echo %blue_fg_strong%[INFO]%reset% autogen has been launched.

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the autogen environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment autogen...
call conda activate autogen

REM Start autogen
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% ChatDev launched in a new window.
start cmd /k "title autogen && cd /d %~dp0bin && python app.py"
goto :home


:update_autogen
title autogen [UPDATE]
cls
echo %blue_fg_strong%/ Home / Update%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the autogen environment
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Conda environment autogen...
call conda activate autogen

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating autogen...
cd /d "%~dp0autogen"
pip install -U "autogen-agentchat" "autogen-ext[openai]"
pause
goto :home


:uninstall_autogen
title autogen [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of AutoGen                                                 ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'autogen'...
    call conda deactivate
    call conda remove --name autogen --all -y
    call conda clean -a -y

    REM Remove the folder autogen
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the autogen directory...
    cd /d "%~dp0"
    rmdir /s /q autogen

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%autogen uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)