@echo off
REM Windows Assessment and Deployment Kit (ADK) Launcher
REM Created by: Deffcolony
REM
REM Description:
REM This script can install and create images with Windows Assessment and Deployment Kit
REM If you want to create ur own unattend.xml go to: https://schneegans.de/windows/unattend-generator/
REM Dont forget to edit startnet.cmd to match ur setup
REM You can also add a custom install background by adding a jpg image to C:\WinPE_amd64\mount\windows\system32\winpe.jpg
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title Windows ADK Launcher


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
set "shortcutTarget=%~dp0adk-launcher.bat"
set "iconFile=%~dp0adk.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=adk-launcher.lnk"
set "startIn=%~dp0"
set "comment=Windows Assessment and Deployment Kit (ADK) Launcher"


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


REM home Frontend
:home
title Windows ADK [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install Windows ADK
echo 2. Run Windows ADK
echo 3. Uninstall Windows ADK
echo 4. Exit


set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
REM if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_win_adk
) else if "%choice%"=="2" (
    call :run_win_adk
) else if "%choice%"=="3" (
    call :uninstall_win_adk
) else if "%choice%"=="4" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:install_win_adk
title Windows ADK [INSTALL]
cls
echo %blue_fg_strong%/ Home / Install Windows ADK%reset%
echo ---------------------------------------------------------------
REM Download and install Windows ADK
REM winget install -e --id Microsoft.WindowsADK

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading Windows ADK...
curl -L -o "%~dp0adksetup.exe" "https://go.microsoft.com/fwlink/?linkid=2243390"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Windows ADK...
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%
start /wait adksetup.exe /quiet /norestart
rem start "" "%~dp0adksetup.exe"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Windows ADK successfully installed.%reset%

REM Download and install Windows PE add-on
REM winget install -e --id Microsoft.ADKPEAddon

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading Windows PE add-on...
curl -L -o "%~dp0adkwinpesetup.exe" "https://go.microsoft.com/fwlink/?linkid=2243391"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Windows PE add-on...
echo %cyan_fg_strong%This may take a while. Please be patient.%reset%
start /wait adkwinpesetup.exe /quiet /norestart
rem start "" "%~dp0adkwinpesetup.exe"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Windows PE add-on successfully installed.%reset%

REM Cleanup downloaded files
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Cleaning up downloaded files...
del "%~dp0adksetup.exe"
del "%~dp0adkwinpesetup.exe"

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


:run_win_adk
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo %red_fg_strong%[ERROR] This part requires administrative privileges. Please run the launcher as Administrator.%reset%
    pause
    goto :home
)
title Windows ADK
cls
echo %blue_fg_strong%/ Home / Run Windows ADK%reset%
echo ---------------------------------------------------------------


REM Navigate to the folder
cd "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64"

md %~dp0WinPE_amd64\mount
timeout /nobreak /t 3 >nul

REM Unmounting the Windows PE boot image if already mounted
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Unmounting the Windows PE boot image if already mounted...
Dism /Unmount-Image /MountDir:"%~dp0WinPE_amd64\mount" /commit >nul 2>&1

REM Mounting the Windows PE boot image
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Mounting the Windows PE boot image...
Dism /Mount-Image /ImageFile:"en-us\winpe.wim" /index:1 /MountDir:"%~dp0WinPE_amd64\mount"

REM Copy files
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Copying files...
Xcopy "%~dp0WinPE_amd64\mount\Windows\Boot\EFI\bootmgr.efi" "Media\bootmgr.efi" /Y
Xcopy "%~dp0WinPE_amd64\mount\Windows\Boot\EFI\bootmgfw.efi" "Media\EFI\Boot\bootx64.efi" /Y

REM Unmount the WinPE image, committing changes
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Unmounting the WinPE image, committing changes...
Dism /Unmount-Image /MountDir:"%~dp0WinPE_amd64\mount" /commit

REM Delete the temp folder
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Deleting the temp folder...
rmdir /s /q %~dp0WinPE_amd64

REM Create working files in a seperate CMD window
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Opening seperate CMD Window for creating working files
start /wait cmd.exe /k ""C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" && copype amd64 %~dp0WinPE_amd64 && exit"

REM Mount the boot.wim
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Mounting boot.wim...
Dism /Mount-Image /ImageFile:"%~dp0WinPE_amd64\media\sources\boot.wim" /index:1 /MountDir:"%~dp0WinPE_amd64\mount"

REM Copy startnet.cmd to mount of boot.wim
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Copying startnet.cmd into boot.wim...
copy /Y "%~dp0startnet.cmd" "%~dp0WinPE_amd64\mount\Windows\System32\startnet.cmd"

REM Copy unattend.xml to mount of boot.wim
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Copying unattend.xml into boot.wim...
copy /Y "%~dp0unattend.xml" "%~dp0WinPE_amd64\mount\unattend.xml"

REM Unmount the boot.wim, committing changes
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Unmounting the boot.wim, committing changes...
Dism /Unmount-Image /MountDir:"%~dp0WinPE_amd64\mount" /commit

REM Build the WinPE ISO in a seperate CMD window
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Opening seperate CMD Window to build bootable WinPE ISO...
start /wait cmd.exe /k ""C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" && MakeWinPEMedia /ISO %~dp0WinPE_amd64 %~dp0WinPE_amd64\WinPE_amd64.iso && exit"

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%You can find the WinPE_amd64.iso at: %~dp0WinPE_amd64\WinPE_amd64.iso%reset%
pause
goto :home


:uninstall_win_adk
title Windows ADK [UNINSTALL]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of Windows ADK                                             ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Uninstall Windows ADK
    winget uninstall --id Microsoft.ADKPEAddon
    winget uninstall --id Microsoft.WindowsADK

    REM Remove the folder WinPE_amd64
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the WinPE_amd64 directory...
    cd /d "%~dp0"
    rmdir /s /q WinPE_amd64

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Windows ADK uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)