@echo off
REM Windows Update Launcher
REM Created by: Deffcolony
REM
REM Description:
REM This script can enable, disable and install windows updates
REM If you want to create ur own unattend.xml go to: https://schneegans.de/windows/unattend-generator/
REM Dont forget to edit startnet.cmd to match ur setup
REM You can also add a custom install background by adding a jpg image to C:\WinPE_amd64\mount\windows\system32\winpe.jpg
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title win-update Launcher


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

REM Environment Variables (7-Zip)
set "zip7_version=7z2301-x64"
set "zip7_install_path=%ProgramFiles%\7-Zip"
set "zip7_download_path=%TEMP%\%zip7_version%.exe"

REM Environment Variables (win-update)
set "win_update_path=%~dp0win-update"
set "pstools_path=%~dp0win-update\PsTools"
set "pstools_download_url=https://download.sysinternals.com/files/PSTools.zip"
set "pstools_download_path=%~dp0win-update\PsTools\PSTools.zip"
set "psexec_path=%~dp0win-update\PsTools\PsExec.exe"


REM Define the paths and filenames for the shortcut creation (win-update-launcher.bat)
set "shortcutTarget=%~dp0win-update-launcher.bat"
set "iconFile=%~dp0logo.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=win-update-launcher.lnk"
set "startIn=%~dp0"
set "comment=Windows Update Launcher"


REM Define variables for logging
set "log_path=%~dp0logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"


REM Update the PATH value to activate the command for the current session
set PATH=%PATH%;%zip7_install_path%

REM Check if 7-Zip is installed
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] 7z command not found in PATH.%reset%
    echo %red_fg_strong%7-Zip is not installed or not found in the system PATH.%reset%
    title win-update [INSTALL-7Z]
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

REM Check if the folder exists
if not exist "%win_update_path%" (
    mkdir "%win_update_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "win-update"  
)


REM Check if the file exists
if not exist "%pstools_path%" (
    mkdir "%pstools_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "PsTools"  
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing PsTools...
    curl -L -o "%pstools_download_path%" "%pstools_download_url%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Extracting PsTools archive...
    7z x "%pstools_download_path%" -o"%pstools_path%"

    del "%pstools_download_path%"
    goto :create_shortcut
) else (
    REM Requesting elevated permissions if not already running as admin
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Checking if running as admin, requesting elevation if not
    if not "%1"=="admin" (powershell start -verb runas '%0' admin & exit /b)

    REM Running script as System account if not already
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Checking if running as System, elevating to System if not
    if not "%2"=="system" (powershell . '%psexec_path%' /accepteula -i -s -d '%0' admin system & exit /b)
    goto :home
)

:create_shortcut
set /p create_shortcut=Do you want to create a shortcut on the desktop? [Y/n] 
if /i "%create_shortcut%"=="Y" (
    REM Create the shortcut
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating shortcut for win-update-launcher...
    %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command ^
        "$WshShell = New-Object -ComObject WScript.Shell; " ^
        "$Shortcut = $WshShell.CreateShortcut('%desktopPath%\%shortcutName%'); " ^
        "$Shortcut.TargetPath = '%shortcutTarget%'; " ^
        "$Shortcut.IconLocation = '%iconFile%'; " ^
        "$Shortcut.WorkingDirectory = '%startIn%'; " ^
        "$Shortcut.Description = '%comment%'; " ^
        "$Shortcut.Save()"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Shortcut created on the desktop.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%PsTools installed successfully.%reset%
    pause
    
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%PsTools installed successfully.%reset%
    pause
    REM Requesting elevated permissions if not already running as admin
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Checking if running as admin, requesting elevation if not
    if not "%1"=="admin" (powershell start -verb runas '%0' admin & exit /b)

    REM Running script as System account if not already
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Checking if running as System, elevating to System if not
    if not "%2"=="system" (powershell . '%psexec_path%' /accepteula -i -s -d '%0' admin system & exit /b)
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%PsTools installed successfully.%reset%
    pause

    REM Requesting elevated permissions if not already running as admin
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Checking if running as admin, requesting elevation if not
    if not "%1"=="admin" (powershell start -verb runas '%0' admin & exit /b)

    REM Running script as System account if not already
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Checking if running as System, elevating to System if not
    if not "%2"=="system" (powershell . '%psexec_path%' /accepteula -i -s -d '%0' admin system & exit /b)
)



REM ############################################################
REM ############## HOME - FRONTEND #############################
REM ############################################################
:home
title win-update [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------------------------------
echo What would you like to do?

echo 1. Disable Windows Update
echo 2. Enable Windows Update
echo 3. Install Windows Update
echo 0. Exit

set /p choice=Choose Your Destiny: 

REM ############## UPDATE MANAGER - BACKEND ####################
if "%choice%"=="1" (
    call :disable_windows_update
) else if "%choice%"=="2" (
    call :enable_windows_update
) else if "%choice%"=="3" (
    call :install_windows_update
) else if "%choice%"=="0" (
    exit
) else (
    echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


:disable_windows_update
title win-update [DISABLE WINDOWS UPDATE]

REM Disable update related services
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Disabling Windows Update related services
for %%i in (wuauserv, UsoSvc, uhssvc, WaaSMedicSvc) do (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Stopping service: %%i
    net stop %%i
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Disabling service: %%i
    sc config %%i start= disabled
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing failure actions for service: %%i
    sc failure %%i reset= 0 actions= ""
)

REM Brute force rename services
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Renaming WaaSMedicSvc.dll to prevent it from running
for %%i in (WaaSMedicSvc) do (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Taking ownership of %%i.dll
    takeown /f C:\Windows\System32\%%i.dll && icacls C:\Windows\System32\%%i.dll /grant *S-1-1-0:F
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Renaming %%i.dll to %%i_BAK.dll
    rename C:\Windows\System32\%%i.dll %%i_BAK.dll
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Restoring original permissions for %%i_BAK.dll
    icacls C:\Windows\System32\%%i_BAK.dll /setowner "NT SERVICE\TrustedInstaller" && icacls C:\Windows\System32\%%i_BAK.dll /remove *S-1-1-0
)

REM Update registry
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating registry to disable WaaSMedicSvc
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating failure actions for WaaSMedicSvc in registry
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v FailureActions /t REG_BINARY /d 000000000000000000000000030000001400000000000000c0d4010000000000e09304000000000000000000 /f
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Disabling automatic updates in registry
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

REM Delete downloaded update files
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Deleting downloaded windows update files
erase /f /s /q c:\windows\softwaredistribution\*.* && rmdir /s /q c:\windows\softwaredistribution

REM Disable all update related scheduled tasks
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Disabling all update related scheduled tasks
powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\InstallService\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateAssistant\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\WaaSMedic\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\WindowsUpdate\*' | Disable-ScheduledTask"

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Windows Update disabled successfully.%reset%
pause
goto :home


:enable_windows_update
REM Enable update related services
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Enabling Windows Update related services
sc config wuauserv start= auto
sc config UsoSvc start= auto
sc config uhssvc start= delayed-auto

REM Restore renamed services
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Restoring renamed WaaSMedicSvc.dll
for %%i in (WaaSMedicSvc) do (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Taking ownership of %%i_BAK.dll
    takeown /f C:\Windows\System32\%%i_BAK.dll && icacls C:\Windows\System32\%%i_BAK.dll /grant *S-1-1-0:F
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Renaming %%i_BAK.dll back to %%i.dll
    rename C:\Windows\System32\%%i_BAK.dll %%i.dll
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Restoring original permissions for %%i.dll
	icacls C:\Windows\System32\%%i.dll /setowner "NT SERVICE\TrustedInstaller" && icacls C:\Windows\System32\%%i.dll /remove *S-1-1-0
)

REM Update registry
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating registry to enable WaaSMedicSvc
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 3 /f
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating failure actions for WaaSMedicSvc in registry
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v FailureActions /t REG_BINARY /d 840300000000000000000000030000001400000001000000c0d4010001000000e09304000000000000000000 /f
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing NoAutoUpdate policy from registry
reg delete "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /f

REM Enable all update related scheduled tasks
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Enabling all update related scheduled tasks
powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\InstallService\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateAssistant\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\WaaSMedic\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\WindowsUpdate\*' | Enable-ScheduledTask"

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Windows Update enabled successfully.%reset%
pause
goto :home


:install_windows_update
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Checking for windows updates...
usoclient StartScan

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading updates...
usoclient StartDownload

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing updates...
usoclient StartInstall

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Restarting if needed...
usoclient RestartDevice

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Windows Updates installed successfully.%reset%
pause
goto :home