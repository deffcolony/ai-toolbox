@echo off

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
set "yellow_bg=[43m"
set "green_bg=[42m"


set "versions=11.0 12.0 14.0 15.0 16.0"


:reset_outlook
title OUTLOOK HELPER [RESET OUTLOOK]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will reset Microsoft Outlook to factory settings                                ║%reset%
echo %red_bg%║ for ALL Office versions Office 2003 to Office 2024.                                           ║%reset%
echo %red_bg%║                                                                                               ║%reset%
echo %red_bg%║ This action will:                                                                             ║%reset%
echo %red_bg%║ - Delete all Outlook profiles and settings                                                    ║%reset%
echo %red_bg%║ - Remove all locally stored Outlook data                                                      ║%reset%
echo %red_bg%║                                                                                               ║%reset%
echo %red_bg%║ Please ensure you have backed up any important information.                                   ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Close Outlook if it is running
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Shutting down: %cyan_fg_strong%outlook.exe%reset%
    taskkill /IM outlook.exe /F

    REM Loop through each Office version and delete Outlook profiles and settings
    for %%v in (%versions%) do (
        echo Removing Outlook profiles for Office version %%v...
        reg delete "HKCU\Software\Microsoft\Office\%%v\Outlook\Profiles" /f

        echo Removing additional Outlook registry settings for Office version %%v...
        reg delete "HKCU\Software\Microsoft\Office\%%v\Outlook" /f
    )

    REM Delete local Outlook data
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Deleting local Outlook data...%reset%
    rmdir /S /Q "%LocalAppData%\Microsoft\Outlook"
    rmdir /S /Q "%AppData%\Microsoft\Outlook"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Outlook has been reset to factory settings for all Office versions. Please restart your computer and open Outlook to sign in again.%reset%
    pause
    exit
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Operation canceled. No changes were made.
    pause
    exit
)
