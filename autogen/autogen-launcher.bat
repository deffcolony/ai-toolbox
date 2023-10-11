@echo off
REM --------------------------------------------
REM This script was created by: Deffcolony
REM --------------------------------------------
REM Github: https://github.com/microsoft/autogen
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
set "shortcutTarget=%~dp0autogen-launcher.bat"
REM set "iconFile=%SystemRoot%\System32\SHELL32.dll,153"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=AutoGen-Launcher.lnk"
set "startIn=%~dp0"
set "comment=AutoGen Launcher"


REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_fg_strong%[WARN] Winget is not installed on this system.%reset%
    echo %blue_fg_strong%[INFO]%reset% Installing Winget...
    bitsadmin /transfer "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" /download /priority FOREGROUND "https://github.com/microsoft/winget-cli/releases/download/v1.5.2201/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    start "" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    echo %green_fg_strong%Winget is now installed.%reset%
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
    echo %green_fg_strong%winget added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] winget already exists in PATH.%reset%
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
echo 5. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :installautogen
) else if "%choice%"=="2" (
    call :configureautogen
) else if "%choice%"=="3" (
    call :runautogen
) else if "%choice%"=="4" (
    call :updateautogen
) else if "%choice%"=="5" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:installautogen
title autogen [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install autogen%reset%
echo ---------------------------------------------------------------
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

echo %blue_fg_strong%[INFO]%reset% Installing autogen...

winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named autogen
call conda create -n autogen -y 

REM Activate the autogen environment
call conda activate autogen

REM Install Python 3.11 and Git in the autogen environment
call conda install python=3.11.4 git -y

REM Create & Navigate to the autogen directory
mkdir autogen && cd autogen

REM Install AutoGen package from pip
pip install pyautogen

echo %green_fg_strong%autogen Installed Successfully.%reset%

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


:configureautogen
title autogen [CONFIGURE]
cls
echo %blue_fg_strong%/ Home / Configure autogen%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"
echo %blue_fg_strong%[INFO]%reset% Running autogen...

REM Activate the autogen environment
call conda activate autogen

cls
echo %blue_fg_strong%/ Home / Configure autogen%reset%
echo ---------------------------------------------------------------

echo COMMING SOON
pause
goto :home


:runautogen
title autogen
cls
echo %blue_fg_strong%/ Home / Run autogen%reset%
echo ---------------------------------------------------------------
echo %blue_fg_strong%[INFO]%reset% autogen has been launched.
cd /d "%~dp0autogen"
start cmd /k python app.py
goto :home


:updateautogen
title autogen [UPDATE]
cls
echo %blue_fg_strong%/ Home / Update%reset%
echo ---------------------------------------------------------------
echo Updating...
cd /d "%~dp0autogen"
pip install --upgrade pyautogen
pause
goto :home