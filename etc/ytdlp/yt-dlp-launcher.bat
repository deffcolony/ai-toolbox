@echo off
REM YT-DLP Launcher
REM Created by: Deffcolony
REM
REM Description:
REM This script can download stuff from youtube and other social media
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/deffcolony/ai-toolbox
REM Issues: https://github.com/deffcolony/ai-toolbox/issues
title YT-DLP [STARTUP CHECK]
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
set "yellow_bg=[43m"

REM Environment Variables (winget)
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"

REM Environment Variables (7-Zip)
set "zip7_version=7z2301-x64"
set "zip7_install_path=%ProgramFiles%\7-Zip"
set "zip7_download_path=%TEMP%\%zip7_version%.exe"

REM Environment Variables (FFmpeg)
set "ffmpeg_url=https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
set "ffmpeg_download_path=%~dp0yt-dlp-downloads\ffmpeg.7z"
set "ffmpeg_extract_path=C:\ffmpeg"
set "ffmpeg_path_bin=%ffmpeg_extract_path%\bin"

REM Environment Variables (YT-DLP)
set "ytdlp_download_url=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
set "ytdlp_download_path=%~dp0yt-dlp-downloads\yt-dlp.exe"
set "ytdlp_audio_path=%~dp0yt-dlp-downloads\audio"
set "ytdlp_video_path=%~dp0yt-dlp-downloads\video"
set "ytdlp_settings_path=%~dp0yt-dlp-downloads\settings"
set "ytdlp_path=%~dp0yt-dlp-downloads"

REM Define variables to track module status (audio)
set "audio_modules_path=%~dp0yt-dlp-downloads\settings\modules-audio.txt"
set "audio_sponsorblock_trigger=false"
set "audio_format_trigger=false"
set "audio_quality_trigger=false"
set "audio_acodec_trigger=false"
set "audio_metadata_trigger=false"

REM Define variables to track module status (video)
set "video_modules_path=%~dp0yt-dlp-downloads\settings\modules-video.txt"
set "video_sponsorblock_trigger=false"
set "video_mergeoutputformat_trigger=false"
set "video_resolution_trigger=false"
set "video_acodec_trigger=false"
set "video_vcodec_trigger=false"
set "video_metadata_trigger=false"


REM Define the paths and filenames for the shortcut creation (yt-dlp-launcher.bat)
set "shortcutTarget=%~dp0yt-dlp-launcher.bat"
set "iconFile=%~dp0logo.ico"
set "desktopPath=%userprofile%\Desktop"
set "shortcutName=yt-dlp-launcher.lnk"
set "startIn=%~dp0"
set "comment=yt-dlp-launcher"


REM Define variables for logging
set "log_path=%~dp0yt-dlp-downloads\logs.log"
set "log_invalidinput=[ERROR] Invalid input. Please enter a valid number."
set "echo_invalidinput=%red_fg_strong%[ERROR] Invalid input. Please enter a valid number.%reset%"

cd /d "%~dp0"

REM Check if folder path has no spaces
echo "%CD%"| findstr /C:" " >nul && (
    echo %red_fg_strong%[ERROR] Path cannot have spaces! Please remove them or replace with: - %reset%
    echo Folders containing spaces makes the launcher unstable
    echo path: %red_bg%%~dp0%reset%
    pause
    exit /b 1
)

REM Check if folder path has no special characters
echo "%CD%"| findstr /R /C:"[!#\$%&()\*+,;<=>?@\[\]\^`{|}~]" >nul && (
    echo %red_fg_strong%[ERROR] Path cannot have special characters! Please remove them.%reset%
    echo Folders containing special characters makes the launcher unstable for the following: "[!#\$%&()\*+,;<=>?@\[\]\^`{|}~]" 
    echo path: %red_bg%%~dp0%reset%
    pause
    exit /b 1
)

REM Check if the folder exists
if not exist "%ytdlp_path%" (
    mkdir "%ytdlp_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "yt-dlp-downloads"  
)
REM Check if the folder exists
if not exist "%ytdlp_audio_path%" (
    mkdir "%ytdlp_audio_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "audio"  
)
REM Check if the folder exists
if not exist "%ytdlp_video_path%" (
    mkdir "%ytdlp_video_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "video"  
)
REM Check if the folder exists
if not exist "%ytdlp_settings_path%" (
    mkdir "%ytdlp_settings_path%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "settings"  
)
REM Create modules-audio if it doesn't exist
if not exist %audio_modules_path% (
    type nul > %audio_modules_path%
)
REM Load modules-audio flags from modules
for /f "tokens=*" %%a in (%audio_modules_path%) do set "%%a"

REM Create modules-video if it doesn't exist
if not exist %video_modules_path% (
    type nul > %video_modules_path%
)
REM Load modules-video flags from modules-video
for /f "tokens=*" %%a in (%video_modules_path%) do set "%%a"



REM Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

REM Check if the paths are already in the current PATH
echo %current_path% | find /i "%winget_path%" > nul
set "ff_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %ff_path_exists% neq 0 (
    set "new_path=%current_path%;%winget_path%"
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "winget_path is:%cyan_fg_strong% %winget_path%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%winget added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] winget already exists in PATH.%reset%
)

REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Winget is not installed on this system.%reset%
    REM Check if the folder exists
    if not exist "%~dp0bin" (
        mkdir "%~dp0bin"
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Created folder: "bin"  
    ) else (
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO] "bin" folder already exists.%reset%
    )
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Winget...
    curl -L -o "%~dp0bin\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    start "" "%~dp0bin\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Winget installed successfully. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Winget is already installed.%reset%
)

REM Check if Git is installed if not then install git
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Git is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Git using Winget...
    winget install -e --id Git.Git
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Git is installed. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Git is already installed.%reset%
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

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-zip added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] 7-Zip already exists in PATH.%reset%
)


rem Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

rem Check if the paths are already in the current PATH
echo %current_path% | find /i "%ffmpeg_path_bin%" > nul
set "ff_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %ff_path_exists% neq 0 (
    set "new_path=%current_path%;%ffmpeg_path_bin%"
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "ffmpeg_path_bin is:%cyan_fg_strong% %ffmpeg_path_bin%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ffmpeg added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] ffmpeg already exists in PATH.%reset%
)


REM Check if 7-Zip is installed
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] 7z command not found in PATH.%reset%
    echo %red_fg_strong%7-Zip is not installed or not found in the system PATH.%reset%
    title YT-DLP [INSTALL-7Z]
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing 7-Zip...
    winget install -e --id 7zip.7zip

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-Zip installed successfully. Please restart yt-dlp-launcher%reset%
    pause
    exit
)

REM Check if ffmpeg is installed
if not exist "%ffmpeg_extract_path%" (
    title YT-DLP [INSTALL-FFMPEG]
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading FFmpeg archive...
    curl -L -o "%ffmpeg_download_path%" "%ffmpeg_url%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating ffmpeg directory if it doesn't exist...
    if not exist "%ffmpeg_extract_path%" (
        mkdir "%ffmpeg_extract_path%"
    )

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Extracting FFmpeg archive...
    7z x "%ffmpeg_download_path%" -o"%ffmpeg_extract_path%"


    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Moving FFmpeg contents to C:\ffmpeg...
    for /d %%i in ("%ffmpeg_extract_path%\ffmpeg-*-full_build") do (
        xcopy "%%i\bin" "%ffmpeg_extract_path%\bin" /E /I /Y
        xcopy "%%i\doc" "%ffmpeg_extract_path%\doc" /E /I /Y
        xcopy "%%i\presets" "%ffmpeg_extract_path%\presets" /E /I /Y
        rd "%%i" /S /Q
    )
    del "%ffmpeg_download_path%"
)


REM Check if the file exists
if not exist "%ytdlp_download_path%" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing yt-dlp...
    curl -L -o "%ytdlp_download_path%" "%ytdlp_download_url%"
    goto :create_shortcut
) else (
    goto :home
)

:create_shortcut
set /p create_shortcut=Do you want to create a shortcut on the desktop? [Y/n] 
if /i "%create_shortcut%"=="Y" (
    REM Create the shortcut
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating shortcut for yt-dlp-launcher...
    %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command ^
        "$WshShell = New-Object -ComObject WScript.Shell; " ^
        "$Shortcut = $WshShell.CreateShortcut('%desktopPath%\%shortcutName%'); " ^
        "$Shortcut.TargetPath = '%shortcutTarget%'; " ^
        "$Shortcut.IconLocation = '%iconFile%'; " ^
        "$Shortcut.WorkingDirectory = '%startIn%'; " ^
        "$Shortcut.Description = '%comment%'; " ^
        "$Shortcut.Save()"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Shortcut created on the desktop.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%yt-dlp installed successfully. Please restart yt-dlp-launcher%reset%
    pause
    exit
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%yt-dlp installed successfully. Please restart yt-dlp-launcher%reset%
    pause
    exit
)

REM Change the directory
cd /d "%ytdlp_path%"

REM ############################################################
REM ################## HOME - FRONTEND #########################
REM ############################################################
:home
title YT-DLP [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------------------------------
echo What would you like to do?
echo 1. Download mp3 audio
echo 2. Download mp4 video
echo 3. Editor
echo 4. Update
echo 5. Uninstall yt-dlp
echo 0. Exit

set "choice="
set /p "choice=Choose Your Destiny: "

REM Default to choice 1 if no input is provided
REM if not defined choice set "choice=1"

REM ################## HOME - BACKEND #########################
if "%choice%"=="1" (
    call :start_ytdlp_mp3
) else if "%choice%"=="2" (
    call :start_ytdlp_mp4
) else if "%choice%"=="3" (
    call :editor
) else if "%choice%"=="4" (
    call :update_ytdlp
) else if "%choice%"=="5" (
    call :uninstall_ytdlp
)   else if "%choice%"=="0" (
    exit
) else (
    echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)

:start_ytdlp_mp3
title YT-DLP [DOWNLOAD MP3]
cls
set /p weburl="(0 to cancel) Insert URL: "

if "%weburl%"=="0" goto :home

REM Check if the URL input starts with "http", "https", or "www"
echo %weburl% | findstr /R /C:"^https*://" /C:"^www\." > nul
if errorlevel 1 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Invalid input. Please enter a valid URL.%reset%
    echo %red_fg_strong%URL must start with one of the following: http://, https://, or www.%reset%
    pause
    goto :start_ytdlp_mp3
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading audio...
REM echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading... "%ytdlp_download_path%" --print filename -o "%(title)s.%(ext)s" %weburl%
"%ytdlp_download_path%" -P "%ytdlp_audio_path%" %audio_start_command% -f ba/b -x --embed-metadata --embed-chapters --embed-thumbnail -o "%%(title)s.%%(ext)s" -w %weburl% && echo [%DATE% %TIME%] [AUDIO] - %weburl%>>"%log_path%"
pause
goto :home


:start_ytdlp_mp4
title YT-DLP [DOWNLOAD MP4]
cls
set /p weburl="(0 to cancel) Insert URL: "

if "%weburl%"=="0" goto :home

REM Check if the URL input starts with "http", "https", or "www"
echo %weburl% | findstr /R /C:"^https*://" /C:"^www\." > nul
if errorlevel 1 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Invalid input. Please enter a valid URL.%reset%
    echo %red_fg_strong%URL must start with one of the following: http://, https://, or www.%reset%
    pause
    goto :start_ytdlp_mp4
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading video... 
REM echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading... "%ytdlp_download_path%" --print filename -o "%(title)s.%(ext)s" %weburl%

REM Read modules-video and find the video_start_command line
set "video_start_command="
for /F "tokens=*" %%a in ('findstr /I "video_start_command=" "%video_modules_path%"') do (
    set "%%a"
)
set "video_start_command=%video_start_command:video_start_command=%"

"%ytdlp_download_path%" -P "%ytdlp_video_path%" %video_start_command% -o "%%(title)s.%%(ext)s" -w %weburl% && echo [%DATE% %TIME%] [VIDEO] - %weburl%>>"%log_path%"
pause
goto :home


REM ############################################################
REM ################# EDITOR - FRONTEND ########################
REM ############################################################
:editor
title YT-DLP [EDITOR]
cls
echo %blue_fg_strong%/ Home / Editor%reset%
echo -------------------------------------------------------------
echo What would you like to do?

echo 1. Edit Audio Modules
echo 2. Edit Video Modules 
echo 0. Back

set /p editor_choice=Choose Your Destiny: 

REM ################# EDITOR - BACKEND ########################
if "%editor_choice%"=="1" (
    call :edit_audio_modules
) else if "%editor_choice%"=="2" (
    call :edit_video_modules
) else if "%editor_choice%"=="0" (
    goto :home
) else (
    echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :editor
)

REM ##################################################################################################################################################
REM ##################################################################################################################################################
REM ##################################################################################################################################################


REM Function to print module options with color based on their status
:printModule
if "%2"=="true" (
    echo %green_fg_strong%%1 [Enabled]%reset%
) else (
    echo %red_fg_strong%%1 [Disabled]%reset%
)
exit /b

REM ############################################################
REM ############## EDIT AUDIO MODULES - FRONTEND ###############
REM ############################################################
:edit_audio_modules
title YT-DLP [EDIT AUDIO MODULES]
cls
echo %blue_fg_strong%/ Home / Editor / Edit Audio Modules%reset%
echo -------------------------------------------------------------
echo Choose Audio modules to enable or disable

REM Display module options with colors based on their status
call :printModule "1. SponsorBlock (--sponsorblock-remove all)" %audio_sponsorblock_trigger%
call :printModule "2. Audio Format (--audio-format %audio_format%)" %audio_format_trigger%
call :printModule "3. Audio Quality (--audio-quality %audio_quality%)" %audio_quality_trigger%
call :printModule "4. Audio Codec (-S acodec:%audio_acodec%)" %audio_acodec_trigger%
call :printModule "5. Metadata (--embed-metadata --embed-chapters --embed-thumbnail)" %audio_metadata_trigger%
call :printModule "6. verbose (--verbose)" %audio_verbose_trigger%

echo 00. Quick Download Audio
echo 0. Back

set "audio_command="

set /p audio_module_choices=Choose modules to enable/disable: 

REM Handle the user's module choices and construct the Python command
for %%i in (%audio_module_choices%) do (
    if "%%i"=="1" (
        if "%audio_sponsorblock_trigger%"=="true" (
            set "audio_sponsorblock_trigger=false"
        ) else (
            set "audio_sponsorblock_trigger=true"
        )

    ) else if "%%i"=="2" (
        if "%audio_format_trigger%"=="true" (
            set "audio_format_trigger=false"
            goto :save_module_choise
        ) else (
            set "audio_format_trigger=true"
        )

        REM ############## SELECT AUDIO FORMAT - FRONTEND ###############
        :audio_format_menu
        title YT-DLP [SELECT AUDIO FORMAT]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Audio Modules / SELECT AUDIO FORMAT%reset%
        echo -------------------------------------------------------------
        echo Select Audio Codec:
        echo 1. mp3
        echo 2. wav
        echo 3. flac
        echo 4. opus
        echo 5. vorbis
        echo 6. aac
        echo 7. m4a
        echo 8. alac
        set /p audio_format_choice=Choose Your Destiny: 

        REM ############## SELECT AUDIO FORMAT - BACKEND ################
        if "%audio_format_choice%"=="1" (
            set "audio_format=mp3"
            goto :save_module_choise
        ) else if "%audio_format_choice%"=="2" (
            set "audio_format=wav"
            goto :save_module_choise
        ) else if "%audio_format_choice%"=="3" (
            set "audio_format=flac"
            goto :save_module_choise
        ) else if "%audio_format_choice%"=="4" (
            set "audio_format=opus"
            goto :save_module_choise
        ) else if "%audio_format_choice%"=="5" (
            set "audio_format=vorbis"
            goto :save_module_choise
        ) else if "%audio_format_choice%"=="6" (
            set "audio_format=aac"
            goto :save_module_choise
        ) else if "%audio_format_choice%"=="7" (
            set "audio_format=m4a"
            goto :save_module_choise
        ) else if "%audio_format_choice%"=="8" (
            set "audio_format=alac"
            goto :save_module_choise
        ) else (
            echo [%DATE% %TIME%] [audio_format_menu] %log_invalidinput% >> %log_path%
            echo %red_bg%[%time%] [audio_format_menu]%reset% %echo_invalidinput%
            pause
            goto :audio_format_menu
        )


    ) else if "%%i"=="3" (
        if "%audio_quality_trigger%"=="true" (
            set "audio_quality_trigger=false"
            goto :save_module_choise
        ) else (
            set "audio_quality_trigger=true"
        )

        REM ############## SELECT AUDIO QUALITY - FRONTEND ###############
        :audio_quality_menu
        title YT-DLP [SELECT AUDIO QUALITY]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Audio Modules / SELECT AUDIO QUALITY%reset%
        echo -------------------------------------------------------------
        echo Select Audio Quality:
        echo 1. [0 Best]
        echo 2. [1]
        echo 3. [2]
        echo 4. [3]
        echo 5. [4]
        echo 6. [5]
        echo 7. [6]
        echo 8. [7]
        echo 9. [8]
        echo 10. [9]
        echo 11. [10 Worst]
        set /p audio_quality_choice=Choose Your Destiny: 

        REM ############## SELECT AUDIO QUALITY - BACKEND ################
        if "%audio_quality_choice%"=="1" (
            set "audio_quality=0"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="2" (
            set "audio_quality=1"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="3" (
            set "audio_quality=2"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="4" (
            set "audio_quality=3"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="5" (
            set "audio_quality=4"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="6" (
            set "audio_quality=5"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="7" (
            set "audio_quality=6"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="8" (
            set "audio_quality=7"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="9" (
            set "audio_quality=8"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="10" (
            set "audio_quality=9"
            goto :save_module_choise
        ) else if "%audio_quality_choice%"=="11" (
            set "audio_quality=10"
            goto :save_module_choise
        ) else (
            echo [%DATE% %TIME%] [audio_quality_menu] %log_invalidinput% >> %log_path%
            echo %red_bg%[%time%] [audio_quality_menu]%reset% %echo_invalidinput%
            pause
            goto :audio_quality_menu
        )

    ) else if "%%i"=="4" (
        if "%audio_acodec_trigger%"=="true" (
            set "audio_acodec_trigger=false"
            goto :save_module_choise
        ) else (
            set "audio_acodec_trigger=true"
        )

        REM ############## SELECT AUDIO CODEC - FRONTEND ###############
        :audio_acodec_menu
        title YT-DLP [SELECT AUDIO CODEC]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Video Modules / SELECT AUDIO CODEC%reset%
        echo -------------------------------------------------------------
        echo Select Audio Codec:
        echo 1. mp3
        echo 2. wav
        echo 3. flac
        echo 4. opus
        echo 5. vorbis
        echo 6. aac
        echo 7. mp4a
        echo 8. ac4
        set /p audio_acodec_choice=Choose Your Destiny: 

        REM ############## SELECT AUDIO CODEC - BACKEND ################
        if "%audio_acodec_choice%"=="1" (
            set "audio_acodec=mp3"
            goto :save_module_choise
        ) else if "%audio_acodec_choice%"=="2" (
            set "audio_acodec=wav"
            goto :save_module_choise
        ) else if "%audio_acodec_choice%"=="3" (
            set "audio_acodec=flac"
            goto :save_module_choise
        ) else if "%audio_acodec_choice%"=="4" (
            set "audio_acodec=opus"
            goto :save_module_choise
        ) else if "%audio_acodec_choice%"=="5" (
            set "audio_acodec=vorbis"
            goto :save_module_choise
        ) else if "%audio_acodec_choice%"=="6" (
            set "audio_acodec=aac"
            goto :save_module_choise
        ) else if "%audio_acodec_choice%"=="7" (
            set "audio_acodec=mp4a"
            goto :save_module_choise
        ) else if "%audio_acodec_choice%"=="8" (
            set "audio_acodec=ac4"
            goto :save_module_choise
        ) else (
            echo [%DATE% %TIME%] [audio_acodec_menu] %log_invalidinput% >> %log_path%
            echo %red_bg%[%time%] [audio_acodec_menu]%reset% %echo_invalidinput%
            pause
            goto :audio_acodec_menu
        )

    ) else if "%%i"=="5" (
        if "%audio_metadata_trigger%"=="true" (
            set "audio_metadata_trigger=false"
        ) else (
            set "audio_metadata_trigger=true"
        )
    ) else if "%%i"=="6" (
        if "%audio_verbose_trigger%"=="true" (
            set "audio_verbose_trigger=false"
        ) else (
            set "audio_verbose_trigger=true"
        )

    ) else if "%%i"=="00" (
        goto :start_ytdlp_mp3

    ) else if "%%i"=="0" (
        goto :editor
    )
)

REM Save the module flags to modules-audio
echo audio_sponsorblock_trigger=%audio_sponsorblock_trigger%>%audio_modules_path%
echo audio_format_trigger=%audio_format_trigger%>>%audio_modules_path%
echo audio_quality_trigger=%audio_quality_trigger%>>%audio_modules_path%
echo audio_acodec_trigger=%audio_acodec_trigger%>>%audio_modules_path%
echo audio_metadata_trigger=%audio_metadata_trigger%>>%audio_modules_path%
echo audio_verbose_trigger=%audio_verbose_trigger%>>%audio_modules_path%


REM remove modules_enable
set "modules_enable="

REM Compile the Python command
set "audio_command= "
if "%audio_sponsorblock_trigger%"=="true" (
    set "audio_command=%audio_command% --sponsorblock-remove all"
)
if "%audio_format_trigger%"=="true" (
    set "audio_command=%audio_command% --audio-format %audio_format%"
)
if "%audio_quality_trigger%"=="true" (
    set "audio_command=%audio_command% --audio-quality %audio_quality%"
)
if "%audio_acodec_trigger%"=="true" (
    set "audio_command=%audio_command% -S acodec:%audio_acodec%"
)
if "%audio_metadata_trigger%"=="true" (
    set "audio_command=%audio_command% --embed-metadata --embed-chapters --embed-thumbnail"
)
if "%audio_verbose_trigger%"=="true" (
    set "audio_command=%audio_command% --verbose"
)


REM is modules_enable empty?
if defined modules_enable (
    REM remove last comma
    set "modules_enable=%modules_enable:~0,-1%"
)

REM command completed
if defined modules_enable (
    set "audio_command=%audio_command% --enable-modules=%modules_enable%"
)

REM Save the constructed Python command to modules-audio for testing
echo audio_start_command=%audio_command%>>%audio_modules_path%
goto :edit_audio_modules



REM ##################################################################################################################################################
REM ##################################################################################################################################################
REM ##################################################################################################################################################


REM Function to print module options with color based on their status
:printModule
if "%2"=="true" (
    echo %green_fg_strong%%1 [Enabled]%reset%
) else (
    echo %red_fg_strong%%1 [Disabled]%reset%
)
exit /b

REM ############################################################
REM ############## EDIT VIDEO MODULES - FRONTEND ###############
REM ############################################################
:edit_video_modules
title YT-DLP [EDIT VIDEO MODULES]
cls
echo %blue_fg_strong%/ Home / Editor / Edit Video Modules%reset%
echo -------------------------------------------------------------
echo Choose Video modules to enable or disable.
REM Read modules-video and find the video_start_command line
set "video_start_command="
for /F "tokens=*" %%a in ('findstr /I "video_start_command=" "%video_modules_path%"') do (
    set "%%a"
)
set "video_start_command=%video_start_command:video_start_command=%"
echo Preview: %cyan_fg_strong%%video_start_command%%reset%
echo.

REM Display module options with colors based on their status
call :printModule "1. Sponsor Block (--sponsorblock-remove all)" %video_sponsorblock_trigger%
call :printModule "2. Merge Output Format (--merge-output-format %mergeoutputformat%)" %video_mergeoutputformat_trigger%
call :printModule "3. Resolution (-S res:%video_resolution%)" %video_resolution_trigger%
call :printModule "4. Audio Codec (-S acodec:%video_acodec%)" %video_acodec_trigger%
call :printModule "5. Video Codec (-S vcodec:%video_vcodec%)" %video_vcodec_trigger%
call :printModule "6. Metadata (--embed-metadata --embed-chapters --embed-thumbnail)" %video_metadata_trigger%
echo.
echo 00. Quick Download Video
echo 0. Back

set "video_command="

set /p video_module_choices=Choose modules to enable/disable: 

REM Handle the user's module choices and construct the Python command
for %%i in (%video_module_choices%) do (
    if "%%i"=="1" (
        if "%video_sponsorblock_trigger%"=="true" (
            set "video_sponsorblock_trigger=false"
        ) else (
            set "video_sponsorblock_trigger=true"
        )

    ) else if "%%i"=="2" (
        if "%video_mergeoutputformat_trigger%"=="true" (
            set "video_mergeoutputformat_trigger=false"
            goto :save_module_choise
        ) else (
            set "video_mergeoutputformat_trigger=true"
        )
        
        REM ############## SELECT MERGE OUTPUT FORMAT - FRONTEND ###############
        :mergoutputformat_menu
        title YT-DLP [SELECT MERGE]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Video Modules / SELECT FORMAT%reset%
        echo -------------------------------------------------------------
        echo Select a merge output format:
        echo 1. mp4
        echo 2. flv
        echo 3. mkv
        echo 4. mov
        echo 5. avi
        echo 6. webm
        set /p mergeoutputformat_choice=Choose Your Destiny: 

        REM ############## SELECT MERGE OUTPUT FORMAT - BACKEND ################
        if "%mergeoutputformat_choice%"=="1" (
            set "mergeoutputformat=mp4"
            goto :save_module_choise
        ) else if "%mergeoutputformat_choice%"=="2" (
            set "mergeoutputformat=flv"
            goto :save_module_choise
        ) else if "%mergeoutputformat_choice%"=="3" (
            set "mergeoutputformat=mkv"
            goto :save_module_choise
        ) else if "%mergeoutputformat_choice%"=="4" (
            set "mergeoutputformat=mov"
            goto :save_module_choise
        ) else if "%mergeoutputformat_choice%"=="5" (
            set "mergeoutputformat=avi"
            goto :save_module_choise
        ) else if "%mergeoutputformat_choice%"=="6" (
            set "mergeoutputformat=webm"
            goto :save_module_choise
        ) else (
            echo [%DATE% %TIME%] [mergoutputformat_menu] %log_invalidinput% >> %log_path%
            echo %red_bg%[%time%] [mergoutputformat_menu]%reset% %echo_invalidinput%
            pause
            goto :mergoutputformat_menu
        )

    ) else if "%%i"=="3" (
        if "%video_resolution_trigger%"=="true" (
            set "video_resolution_trigger=false"
            goto :save_module_choise
        ) else (
            set "video_resolution_trigger=true"
        )

        REM ############## SELECT RESOLUTION - FRONTEND ###############
        :video_resolution_menu
        title YT-DLP [SELECT RESOLUTION]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Video Modules / SELECT RESOLUTION%reset%
        echo -------------------------------------------------------------
        echo Select Resolution:
        echo 1. 4320p 8K
        echo 2. 2160p 4K
        echo 3. 1440p HD
        echo 4. 1080p HD
        echo 5. 720p
        echo 6. 480p
        echo 7. 360p
        echo 8. 240p
        echo 9. 144p
        set /p video_resolution_choice=Choose Your Destiny: 

        REM ############## SELECT RESOLUTION - BACKEND ################
        if "%video_resolution_choice%"=="1" (
            set "video_resolution=4320"
            goto :save_module_choise
        ) else if "%video_resolution_choice%"=="2" (
            set "video_resolution=2160"
            goto :save_module_choise
        ) else if "%video_resolution_choice%"=="3" (
            set "video_resolution=1440"
            goto :save_module_choise
        ) else if "%video_resolution_choice%"=="4" (
            set "video_resolution=1080"
            goto :save_module_choise
        ) else if "%video_resolution_choice%"=="5" (
            set "video_resolution=720"
            goto :save_module_choise
        ) else if "%video_resolution_choice%"=="6" (
            set "video_resolution=480"
            goto :save_module_choise
        ) else if "%video_resolution_choice%"=="7" (
            set "video_resolution=360"
            goto :save_module_choise
        ) else if "%video_resolution_choice%"=="8" (
            set "video_resolution=240"
            goto :save_module_choise
        ) else if "%video_resolution_choice%"=="9" (
            set "video_resolution=144"
            goto :save_module_choise
        ) else (
            echo [%DATE% %TIME%] [video_resolution_menu] %log_invalidinput% >> %log_path%
            echo %red_bg%[%time%] [video_resolution_menu]%reset% %echo_invalidinput%
            pause
            goto :video_resolution_menu
        )

    ) else if "%%i"=="4" (
        if "%video_acodec_trigger%"=="true" (
            set "video_acodec_trigger=false"
            goto :save_module_choise
        ) else (
            set "video_acodec_trigger=true"
        )

        REM ############## SELECT AUDIO CODEC - FRONTEND ###############
        :video_acodec_menu
        title YT-DLP [SELECT AUDIO CODEC]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Video Modules / SELECT AUDIO CODEC%reset%
        echo -------------------------------------------------------------
        echo Select Audio Codec:
        echo 1. mp3
        echo 2. wav
        echo 3. flac
        echo 4. opus
        echo 5. vorbis
        echo 6. aac
        echo 7. mp4a
        echo 8. ac4
        set /p video_acodec_choice=Choose Your Destiny: 

        REM ############## SELECT AUDIO CODEC - BACKEND ################
        if "%video_acodec_choice%"=="1" (
            set "video_acodec=mp3"
            goto :save_module_choise
        ) else if "%video_acodec_choice%"=="2" (
            set "video_acodec=wav"
            goto :save_module_choise
        ) else if "%video_acodec_choice%"=="3" (
            set "video_acodec=flac"
            goto :save_module_choise
        ) else if "%video_acodec_choice%"=="4" (
            set "video_acodec=opus"
            goto :save_module_choise
        ) else if "%video_acodec_choice%"=="5" (
            set "video_acodec=vorbis"
            goto :save_module_choise
        ) else if "%video_acodec_choice%"=="6" (
            set "video_acodec=aac"
            goto :save_module_choise
        ) else if "%video_acodec_choice%"=="7" (
            set "video_acodec=mp4a"
            goto :save_module_choise
        ) else if "%video_acodec_choice%"=="8" (
            set "video_acodec=ac4"
            goto :save_module_choise
        ) else (
            echo [%DATE% %TIME%] [video_acodec_menu] %log_invalidinput% >> %log_path%
            echo %red_bg%[%time%] [video_acodec_menu]%reset% %echo_invalidinput%
            pause
            goto :video_acodec_menu
        )

    ) else if "%%i"=="5" (
        if "%video_vcodec_trigger%"=="true" (
            set "video_vcodec_trigger=false"
            goto :save_module_choise
        ) else (
            set "video_vcodec_trigger=true"
        )

        REM ############## SELECT VIDEO CODEC - FRONTEND ###############
        :video_vcodec_menu
        title YT-DLP [SELECT VIDEO CODEC]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Video Modules / SELECT VIDEO CODEC%reset%
        echo -------------------------------------------------------------
        echo Select Video Codec:
        echo 1. h264
        echo 2. h265
        echo 3. h263
        echo 4. av01
        echo 5. vp9.2
        echo 6. vp9
        echo 7. vp8
        echo 8. theora
        set /p video_vcodec_choice=Choose Your Destiny: 

        REM ############## SELECT VIDEO CODEC - BACKEND ################
        if "%video_vcodec_choice%"=="1" (
            set "video_vcodec=h264"
            goto :save_module_choise
        ) else if "%video_vcodec_choice%"=="2" (
            set "video_vcodec=h265"
            goto :save_module_choise
        ) else if "%video_vcodec_choice%"=="3" (
            set "video_vcodec=h263"
            goto :save_module_choise
        ) else if "%video_vcodec_choice%"=="4" (
            set "video_vcodec=av01"
            goto :save_module_choise
        ) else if "%video_vcodec_choice%"=="5" (
            set "video_vcodec=vp9.2"
            goto :save_module_choise
        ) else if "%video_vcodec_choice%"=="6" (
            set "video_vcodec=vp9"
            goto :save_module_choise
        ) else if "%video_vcodec_choice%"=="7" (
            set "video_vcodec=vp8"
            goto :save_module_choise
        ) else if "%video_vcodec_choice%"=="8" (
            set "video_vcodec=theora"
            goto :save_module_choise
        ) else (
            echo [%DATE% %TIME%] [video_vcodec_menu] %log_invalidinput% >> %log_path%
            echo %red_bg%[%time%] [video_vcodec_menu]%reset% %echo_invalidinput%
            pause
            goto :video_vcodec_menu
        )

    ) else if "%%i"=="6" (
        if "%video_metadata_trigger%"=="true" (
            set "video_metadata_trigger=false"
        ) else (
            set "video_metadata_trigger=true"
        )

    ) else if "%%i"=="00" (
        goto :start_ytdlp_mp4

    ) else if "%%i"=="0" (
        goto :editor
    )
)

:save_module_choise
REM Save the module flags to modules-video
echo video_sponsorblock_trigger=%video_sponsorblock_trigger%>%video_modules_path%
echo video_mergeoutputformat_trigger=%video_mergeoutputformat_trigger%>>%video_modules_path%
echo video_resolution_trigger=%video_resolution_trigger%>>%video_modules_path%
echo video_acodec_trigger=%video_acodec_trigger%>>%video_modules_path%
echo video_vcodec_trigger=%video_vcodec_trigger%>>%video_modules_path%
echo video_metadata_trigger=%video_metadata_trigger%>>%video_modules_path%


REM remove modules_enable
set "modules_enable="

REM Compile the Python command
set "video_command= "
if "%video_sponsorblock_trigger%"=="true" (
    set "video_command=%video_command% --sponsorblock-remove all"
)
if "%video_mergeoutputformat_trigger%"=="true" (
    set "video_command=%video_command% --merge-output-format %mergeoutputformat%"
)
if "%video_resolution_trigger%"=="true" (
    set "video_command=%video_command% -S res:%video_resolution%"
)
if "%video_acodec_trigger%"=="true" (
    set "video_command=%video_command% -S acodec:%video_acodec%"
)
if "%video_vcodec_trigger%"=="true" (
    set "video_command=%video_command% -S vcodec:%video_vcodec%"
)
if "%video_metadata_trigger%"=="true" (
    set "video_command=%video_command% --embed-metadata --embed-chapters --embed-thumbnail"
)


REM is modules_enable empty?
if defined modules_enable (
    REM remove last comma
    set "modules_enable=%modules_enable:~0,-1%"
)

REM command completed
if defined modules_enable (
    set "video_command=%video_command% --enable-modules=%modules_enable%"
)

REM Save the constructed Python command to modules-video for testing
echo video_start_command=%video_command%>>%video_modules_path%
goto :edit_video_modules

:update_ytdlp
REM Check if the file exists
if exist "%ytdlp_download_path%" (
    REM Remove yt-dlp if it already exist
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing existing yt-dlp installation...
    del "%ytdlp_download_path%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing yt-dlp...
    curl -L -o "%ytdlp_download_path%" "%ytdlp_download_url%"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%yt-dlp updated successfully.%reset%
    pause
    goto :home
)


:uninstall_ytdlp
title YT-DLP [UNINSTALL YT-DLP]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of yt-dlp                                                  ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the folder
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the YT-DLP directory...
    cd /d "%~dp0"
    rmdir /s /q "%ytdlp_path%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%YT-DLP has been uninstalled successfully.%reset%
    pause
    goto :home
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :home
)

