@echo off
REM --------------------------------------------
REM This script was created by: Deffcolony
REM --------------------------------------------
REM Github: https://github.com/KillianLucas/open-interpreter
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


REM Home Frontend
:home
title open-interpreter [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install Open-Interpreter
echo 2. Run Open-Interpreter
echo 3. Exit


set "choice="
set /p "choice=Choose Your Destiny (default is 1): "

REM Default to choice 1 if no input is provided
if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :installoi
) else if "%choice%"=="2" (
    call :runoi
) else if "%choice%"=="3" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:installoi
title open-interpreter [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install Open-Interpreter%reset%
echo ---------------------------------------------------------------
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%

echo %blue_fg_strong%[INFO]%reset% Installing Open-Interpreter...

winget install -e --id Anaconda.Miniconda3

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Create a Conda environment named openinterpreter
call conda create -n openinterpreter -y 

REM Activate the openinterpreter environment
call conda activate openinterpreter

REM Install Python 3.11 and Git in the openinterpreter environment
call conda install python=3.11.4 git -y

pip install llama-cpp-python
pip install open-interpreter

echo %green_fg_strong%Open-Interpreter Installed Successfully.%reset%
pause
endlocal
goto :home

:runoi
title open-interpreter
cls
echo %blue_fg_strong%/ Home / Run Open-Interpreter%reset%
echo ---------------------------------------------------------------

REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"
echo %blue_fg_strong%[INFO]%reset% Running Open-Interpreter...

REM Activate the openinterpreter environment
call conda activate openinterpreter

call interpreter
pause
goto :home