@echo off
title Win Repair

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

REM Define variables for logging
set "log_path=%~dp0logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"


REM home Frontend
:home
title Win Repair [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Repair Boot
echo 2. Toolbox
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny (default is 1): "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :repair_boot
) else if "%choice%"=="2" (
    call :toolbox
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


:repair_boot
title Win Repair [REPAIR BOOT]
cls
echo %blue_fg_strong%/ Home / Repair Boot%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Starting installation for Windows 11...

REM Search for the drive containing the Windows and not the sources folders
set targetDrive=

for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\Windows (
        if not exist %%d:\sources (
            set targetDrive=%%d:
            goto :foundDrive
        )
    )
)

:foundDrive
if defined targetDrive (
    echo Windows and Users folders found on drive %targetDrive%
    cd /d %targetDrive%\

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 1: Fixing MBR - Master Boot Record
    bootrec /fixmbr

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 2: Fixing Boot Sector
    bootrec /fixboot

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 3: Updating Boot Sector Code for System Partition
    bootsect /nt60 SYS

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 4: Fixing Boot Sector Again
    bootrec /fixboot

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 5: Exporting BCD - Boot Configuration - Data to Backup
    bcdedit /export c:\bcdbackup

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 6: Removing Attributes from BCD File
    attrib c:\boot\bcd -h -r -s

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 7: Renaming Current BCD File to bcd.old
    ren c:\boot\bcd bcd.old

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 8: Rebuilding BCD
    echo Confirm the addition of new boot paths by typing 'y' and pressing Enter.
    bootrec /rebuildbcd

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 9: Checking System Files with SFC - System File Checker
    sfc /scannow /offbootdir=%targetDrive%\ /offwindir=%targetDrive%\Windows

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 10: Repairing Windows Image with DISM
    dism /image:%targetDrive%\ /cleanup-image /restorehealth

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Step 11: Verifying Boot Configuration Data
    bcdedit /enum all

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Successfully Repaired Windows Boot%reset%
    pause
    goto :home
) else (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Windows directory not found on any drive.%reset%
    pause
    goto :home
)


REM Toolbox - Frontend
:toolbox
title Win Repair [TOOLBOX]
cls
echo %blue_fg_strong%/ Home / Toolbox%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Run cmd
echo 2. Run powershell
echo 3. Run regedit
echo 4. Run notepad
echo 5. Run task manager
echo 6. Run network check
echo 0. Back to Home

set /p toolbox_choice=Choose Your Destiny: 

REM Toolbox - Backend
if "%toolbox_choice%"=="1" (
    call :run_cmd
) else if "%toolbox_choice%"=="2" (
    goto :run_powershell
) else if "%toolbox_choice%"=="3" (
    goto :run_regedit
) else if "%toolbox_choice%"=="4" (
    goto :run_notepad
) else if "%toolbox_choice%"=="5" (
    goto :run_taskmgr
) else if "%toolbox_choice%"=="6" (
    goto :run_networkcheck
) else if "%toolbox_choice%"=="0" (
    goto :home
) else (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Invalid number. Please enter a valid number.%reset%
    pause
    goto :toolbox
)


:run_cmd
start cmd
goto :toolbox

:run_powershell
start powershell
goto :toolbox

:run_regedit
start regedit
goto :toolbox

:run_notepad
start notepad
goto :toolbox

:run_taskmgr
start taskmgr
goto :toolbox

:run_networkcheck
REM Retrieve external IP address
for /f "tokens=1* delims=: " %%A in (
  'nslookup myip.opendns.com. resolver1.opendns.com 2^>NUL^|find "Address:"'
) Do set ExtIP=%%B

REM Display results
echo External IP is: %cyan_fg_strong%%ExtIP%%reset%
pause
goto :toolbox