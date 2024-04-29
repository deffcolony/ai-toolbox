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
set "ytdlp_path=%~dp0yt-dlp-downloads"

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
echo 1. Download mp4 video
echo 2. Download mp3 audio
echo 3. Editor
echo 4. Update
echo 5. Uninstall yt-dlp
echo 0. Exit

set "choice="
set /p "choice=Choose Your Destiny (default is 1): "

REM Default to choice 1 if no input is provided
if not defined choice set "choice=1"

REM ################## HOME - BACKEND #########################
if "%choice%"=="1" (
    call :start_ytdlp_mp4
) else if "%choice%"=="2" (
    call :start_ytdlp_mp3
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

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Downloading: %weburl%
"%ytdlp_download_path%" -P "%ytdlp_video_path%" --embed-chapters -f "bv*[height>=4320]+ba/b[height>=4320] / bv*[height>=2160]+ba/b[height>=2160] / bv*[height>=1440]+ba/b[height>=1440] / bv*[height>=1080]+ba/b[height>=1080] / bv+ba/b" --merge-output-format mp4 -S vcodec:h264 -S acodec:mp3 --embed-metadata --embed-thumbnail -o "%%(title)s.%%(ext)s" -w %weburl% && echo [%DATE% %TIME%] [VIDEO] - %weburl%>>"%log_path%"
pause
goto :home


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

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading...
"%ytdlp_download_path%" -P "%ytdlp_audio_path%" --embed-chapters -f "ba/b" -x --audio-format "mp3" -S acodec:mp3 --embed-metadata --embed-thumbnail -o "%%(title)s.%%(ext)s" -w %weburl% && echo [%DATE% %TIME%] [AUDIO] - %weburl%>>"%log_path%"
pause
goto :home


:editor
COMING SOON
pause
goto :home


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

