@echo off
title Win Activator

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
title Win Activator [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. UNINSTALL License Key
echo 2. Install and Activate License Key
echo 0. Exit


set "choice="
set /p "choice=Choose Your Destiny (default is 1): "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :uninstall_license
) else if "%choice%"=="2" (
    call :install_license
) else if "%choice%"=="2" (
    call :toolbox
) else if "%choice%"=="0" (
    exit
) else (
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)

:uninstall_license
title Win Activator [UNINSTALL LICENSE KEY]
cls
echo %blue_fg_strong%/ Home / UNINSTALL License Key%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstalling the current product key...
slmgr.vbs /upk
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the product key from the registry...
slmgr.vbs /cpky
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Clearing the KMS server name...
slmgr.vbs /ckms

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Successfully Removed License Key%reset%
pause
goto :home

:install_license
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo %red_fg_strong%[ERROR] This part requires administrative privileges. Please run as Administrator.%reset%
    pause
    goto :home
)
title Win Activator [INSTALL LICENSE KEY]
cls
echo %blue_fg_strong%/ Home / Install License Key%reset%
echo ---------------------------------------------------------------
setlocal enabledelayedexpansion
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Retrieving available editions for current system...
set "count=0"
for /f "tokens=*" %%i in ('DISM /online /Get-TargetEditions ^| findstr /i "Target Edition:"') do (
    set /a count+=1
    set "edition[!count!]=%%i"
    set "edition[!count!]=!edition[!count!]:Target Edition: =!"
    echo !count!. !edition[!count!]!
)
set /p userChoice="Enter the number corresponding to your desired edition: "
if "%userChoice%"=="" (
    echo No choice entered, defaulting to first edition.
    set "userChoice=1"
)
set "userEdition=!edition[%userChoice%]!"
if not defined userEdition (
    echo Invalid choice entered, please try again.
    pause
    goto :install_license
)
echo You have selected: !userEdition!

set "key="
if "%userEdition%"=="Windows 11 Home" set "key=YTMG3-N6DKC-DKB77-7M9GH-8HVX7"
if "%userEdition%"=="Windows 11 Home N" set "key=4CPRK-NM3K3-X6XXQ-RXX86-WXCHW"
if "%userEdition%"=="Windows 11 Home Single Language" set "key=BT79Q-G7N6G-PGBYW-4YWX6-6F4BT"
if "%userEdition%"=="Windows 11 Home Country Specific" set "key=N2434-X9D7W-8PF6X-8DV9T-8TYMD"
if "%userEdition%"=="Windows 11 Pro" set "key=VK7JG-NPHTM-C97JM-9MPGT-3V66T"
if "%userEdition%"=="Windows 11 Pro N" set "key=2B87N-8KFHP-DKV6R-Y2C8J-PKCKT"
if "%userEdition%"=="Windows 11 Pro for Workstations" set "key=DXG7C-N36C4-C4HTG-X4T3X-2YV77"
if "%userEdition%"=="Windows 11 Pro for Workstations N" set "key=WYPNQ-8C467-V2W6J-TX4WX-WT2RQ"
if "%userEdition%"=="Windows 11 Pro Education" set "key=8PTT6-RNW4C-6V7J2-C2D3X-MHBPB"
if "%userEdition%"=="Windows 11 Pro Education N" set "key=GJTYN-HDMQY-FRR76-HVGC7-QPF8P"
if "%userEdition%"=="Windows 11 Education" set "key=YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY"
if "%userEdition%"=="Windows 11 Education N" set "key=84NGF-MHBT6-FXBX8-QWJK7-DRR8H"
if "%userEdition%"=="Windows 11 Enterprise" set "key=XGVPP-NMH47-7TTHJ-W3FW7-8HV2C"
if "%userEdition%"=="Windows 11 Enterprise N" set "key=WGGHN-J84D6-QYCPR-T7PJ7-X766F"
if "%userEdition%"=="Windows 11 Enterprise G N" set "key=FW7NV-4T673-HF4VX-9X4MM-B4H4T"

if defined key (
    echo -------------------------------------
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Configuring LicenseManager service to start automatically...
    sc config LicenseManager start= auto
    net start LicenseManager

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Configuring Windows Update service to start automatically...
    sc config wuauserv start= auto
    net start wuauserv

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Changing the product key to the selected edition key...
    changepk.exe /productkey %key%

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Successfully Added License Key%reset%
) else (
    echo %red_fg_strong%[ERROR] Invalid edition selected or no key available for the selected edition.%reset%
)
pause
goto :home