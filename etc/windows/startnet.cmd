@echo off
title WinPE Setup

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

REM home Frontend
:home
title WinPE Setup [HOME]
cls
echo %blue_fg_strong%/ Home %reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Install Windows 11
echo 2. Install Windows 10
echo 3. Toolbox
echo 4. Exit


set "choice="
set /p "choice=Choose Your Destiny (default is 1): "

REM Default to choice 1 if no input is provided
REM Disable REM below to enable default choise
if not defined choice set "choice=1"

REM home - Backend
if "%choice%"=="1" (
    call :install_windows11
) else if "%choice%"=="2" (
    call :install_windows10
) else if "%choice%"=="3" (
    call :toolbox
) else if "%choice%"=="4" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:install_windows11
title WinPE Setup [INSTALL WINDOWS 11]
cls
echo %blue_fg_strong%/ Home / Install Windows 11%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Starting installation for Windows 11...

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Checking and bypassing specific setup checks...
for %%s in (sCPU sSecureBoot sTPM) do reg add HKLM\SYSTEM\Setup\LabConfig /f /v Bypass%%sCheck /d 1 /t reg_dword

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Initializing Windows PE environment...
wpeinit

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Connecting to network drive (Z:)...
net use Z: \\YOUR_NETBOOTXYZ_IP\windows\11

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Starting setup with unattended XML...
z:\setup.exe /unattend:x:\unattend.xml


:install_windows10
title WinPE Setup [INSTALL WINDOWS 10]
cls
echo %blue_fg_strong%/ Home / Install Windows 10%reset%
echo ---------------------------------------------------------------
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Starting installation for Windows 10...

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Initializing Windows PE environment...
wpeinit

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Connecting to network drive (Z:)...
net use Z: \\YOUR_NETBOOTXYZ_IP\windows\10

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Starting setup with unattended XML...
z:\setup.exe /unattend:x:\unattend.xml


:toolbox
title WinPE Setup [TOOLBOX]
cls
echo %blue_fg_strong%/ Home / Toolbox%reset%
echo ---------------------------------------------------------------
echo Nothing here yet... You can edit the startnet.cmd script to add extra options if needed.
pause
goto :home