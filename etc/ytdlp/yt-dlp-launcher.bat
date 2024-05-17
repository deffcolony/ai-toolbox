@echo off
setlocal EnableDelayedExpansion
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
set "ffmpeg_download_url=https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
set "ffmpeg_download_path=%~dp0yt-dlp-downloads\ffmpeg.7z"
set "ffmpeg_install_path=C:\ffmpeg"
set "ffmpeg_path_bin=%ffmpeg_install_path%\bin"

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

REM Load audio settings
if exist "%audio_modules_path%" (
    for /F "tokens=*" %%a in (%audio_modules_path%) do (
        set "%%a"
    )
)

REM Create modules-video if it doesn't exist
if not exist %video_modules_path% (
    type nul > %video_modules_path%
)

REM Load video settings
if exist "%video_modules_path%" (
    for /F "tokens=*" %%a in (%video_modules_path%) do (
        set "%%a"
    )
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

    REM Update the PATH value to activate the command on system level
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


REM Update the PATH value to activate the command for the current session
set PATH=%PATH%;%zip7_install_path%;%ffmpeg_path_bin%

REM Check if 7-Zip is installed
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] 7z command not found in PATH.%reset%
    echo %red_fg_strong%7-Zip is not installed or not found in the system PATH.%reset%
    title YT-DLP [INSTALL-7Z]
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

    REM Update the PATH value to activate the command on system level
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ffmpeg added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] ffmpeg already exists in PATH.%reset%
)


REM Check if ffmpeg is installed
if not exist "%ffmpeg_install_path%" (
    title YT-DLP [INSTALL-FFMPEG]
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading FFmpeg archive...
    curl -L -o "%ffmpeg_download_path%" "%ffmpeg_download_url%"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating ffmpeg directory if it doesn't exist...
    if not exist "%ffmpeg_install_path%" (
        mkdir "%ffmpeg_install_path%"
    )

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Extracting FFmpeg archive...
    7z x "%ffmpeg_download_path%" -o"%ffmpeg_install_path%"


    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Moving FFmpeg contents to C:\ffmpeg...
    for /d %%i in ("%ffmpeg_install_path%\ffmpeg-*-full_build") do (
        xcopy "%%i\bin" "%ffmpeg_install_path%\bin" /E /I /Y
        xcopy "%%i\doc" "%ffmpeg_install_path%\doc" /E /I /Y
        xcopy "%%i\presets" "%ffmpeg_install_path%\presets" /E /I /Y
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
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%yt-dlp installed successfully.%reset%
    pause
    start "" yt-dlp-launcher.bat
    exit
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%yt-dlp installed successfully.%reset%
    pause
    start "" yt-dlp-launcher.bat
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

REM Dynamic Menu Choices Setup
set "MenuChoice1=Download mp3 audio"
set "MenuChoice2=Download mp4 video"
set "MenuChoice3=Editor"
set "MenuChoice4=Update"
set "MenuChoice5=Uninstall yt-dlp"
set "MenuChoice0=Exit"

echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------------------------------
echo What would you like to do?

REM Display menu dynamically
for /L %%i in (1,1,5) do (
    if defined MenuChoice%%i echo %%i. !MenuChoice%%i!
)
echo 0. Exit

REM Get user choice
set /p "choice=Choose Your Destiny: "

REM Validate the input before proceeding
if "%choice%"=="0" goto choice0
if "%choice%"=="1" goto choice1
if "%choice%"=="2" goto choice2
if "%choice%"=="3" goto choice3
if "%choice%"=="4" goto choice4
if "%choice%"=="5" goto choice5

echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
echo %red_bg%[%time%]%reset% %echo_invalidinput%
pause
goto :home

:choice1
call :start_ytdlp_mp3

:choice2
call :start_ytdlp_mp4

:choice3
call :editor

:choice4
call :update_ytdlp

:choice5
call :uninstall_ytdlp

:choice0
exit /b
goto :EOF

REM Define a home menu function to be able to call from anywhere
:main_home_menu
REM main menu navigation
echo Returning to Main Menu...
goto :home

REM Validate choice exists
if not defined MenuChoice%choice% (
    echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :home
)


REM Start ytdlp mp3
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
"%ytdlp_download_path%" -P "%ytdlp_audio_path%" %audio_start_command% -f ba/b -x -o "%%(title)s.%%(ext)s" -w %weburl% && echo [%DATE% %TIME%] [AUDIO] - %weburl%>>"%log_path%"

REM Open the output folder when download is finished
start "" "%ytdlp_audio_path%"
pause
goto :home

REM Start ytdlp mp4
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

REM Open the output folder when download is finished
start "" "%ytdlp_video_path%"
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

REM Dynamic Editor Menu Setup
set "EditorChoice1=Edit Audio Modules"
set "EditorChoice2=Edit Video Modules"
set "EditorChoice0=Back to Home"

REM Display editor menu dynamically
for /L %%i in (1,1,2) do (
    if defined EditorChoice%%i echo %%i. !EditorChoice%%i!
)
echo 0. Back to Home

REM Get user choice
set /p "editor_choice=Choose an option: "

REM ################# EDITOR - BACKEND ########################
REM Validate choice exists
if not defined EditorChoice%editor_choice% (
    echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :editor
)

REM Choice execution
goto :editor_choice%editor_choice%

:editor_choice1
call :edit_audio_modules

:editor_choice2
call :edit_video_modules

:editor_choice0
goto :home

REM If invalid choice
echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
echo %red_bg%[%time%]%reset% %echo_invalidinput%
pause
goto :editor


REM ##################################################################################################################################################
REM ###########################################################  EDITOR AUDIO SUB-MODULES   ##########################################################
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

REM Read modules-audio and find the audio_start_command line
set "audio_start_command="
for /F "tokens=*" %%a in ('findstr /I "audio_start_command=" "%audio_modules_path%"') do (
    set "%%a"
)
set "audio_start_command=!audio_start_command:audio_start_command=!"
echo Preview: %cyan_fg_strong%!audio_start_command!%reset%
echo.

REM Display module options with colors based on their status
call :printModule "1. SponsorBlock (--sponsorblock-remove all)" !audio_sponsorblock_trigger!
call :printModule "2. Audio Format (--audio-format !audio_format!)" !audio_format_trigger!
call :printModule "3. Audio Quality (--audio-quality !audio_quality!)" !audio_quality_trigger!
call :printModule "4. Audio Codec (-S acodec:!audio_acodec!)" !audio_acodec_trigger!
call :printModule "5. Metadata (--embed-metadata --embed-chapters --embed-thumbnail)" !audio_metadata_trigger!
call :printModule "6. verbose (--verbose)" !audio_verbose_trigger!

echo.
echo 00. Quick Download Audio
echo 0. Back

set /p audio_module_choices="Choose modules to enable/disable: "

REM Handle the user's module choices and construct the Python command
for %%i in (!audio_module_choices!) do (
    if "%%i"=="1" (
        if "!audio_sponsorblock_trigger!"=="true" (
            set "audio_sponsorblock_trigger=false"
            call :save_audio_settings
        ) else (
            set "audio_sponsorblock_trigger=true"
            call :save_audio_settings
        )
    ) else if "%%i"=="2" (
        call :audio_format_menu
    ) else if "%%i"=="3" (
        call :audio_quality_menu
    ) else if "%%i"=="4" (
        call :audio_acodec_menu
    ) else if "%%i"=="5" (
        if "!audio_metadata_trigger!"=="true" (
            set "audio_metadata_trigger=false"
            call :save_audio_settings
        ) else (
            set "audio_metadata_trigger=true"
            call :save_audio_settings
        )
    ) else if "%%i"=="6" (
        if "!audio_verbose_trigger!"=="true" (
            set "audio_verbose_trigger=false"
            call :save_audio_settings
        ) else (
            set "audio_verbose_trigger=true"
            call :save_audio_settings
        )
    ) else if "%%i"=="00" (
        goto :start_ytdlp_mp3
    ) else if "%%i"=="0" (
        goto :main_home_menu
    )
)

REM Refresh the menu to reflect changes
goto :edit_audio_modules

:audio_format_menu
title YT-DLP [SELECT AUDIO FORMAT]
cls
echo %blue_fg_strong%/ Home / Editor / Edit Audio Modules / SELECT AUDIO FORMAT%reset%
echo -------------------------------------------------------------

REM Define the available formats
set "formats=mp3 wav flac opus vorbis aac m4a alac"
set /a count=1

REM Display format options
for %%a in (%formats%) do (
    echo !count!. %%a
    set /a count+=1
)
echo %red_fg_strong%00. Disable this module%reset%
echo 0. Cancel
set /p audio_format_choice="Your choice: "

REM Handle 'Cancel' selection
if "!audio_format_choice!"=="0" (
    goto :audio-editor-menu
)

REM Handle 'Disable' selection
if "!audio_format_choice!"=="00" (
    set "audio_format_trigger=false"
    call :save_audio_settings
    goto :audio-editor-menu
)

REM Adjust index to map to format list
set /a idx=!audio_format_choice! 
set /a validChoiceMax=count 

REM Set format based on selection and enable the trigger
if "!audio_format_choice!" geq "1" if "!audio_format_choice!" leq "!validChoiceMax!" (
    set /a fcount=1
    for %%a in (%formats%) do (
        if "!fcount!"=="!idx!" (
            set "audio_format=%%a"
            set "audio_format_trigger=true"
            call :save_audio_settings
            goto :audio-editor-menu
        )
        set /a fcount+=1
    )
) else (
    echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :audio_format_menu
)

:audio_quality_menu
title YT-DLP [SELECT AUDIO QUALITY]
cls
echo %blue_fg_strong%/ Home / Editor / Edit Audio Modules / SELECT AUDIO QUALITY%reset%
echo -------------------------------------------------------------

REM Define the available quality levels with explicit mapping to choice numbers
set "quality0=0"
set "quality1=1"
set "quality2=2"
set "quality3=3"
set "quality4=4"
set "quality5=5"
set "quality6=6"
set "quality7=7"
set "quality8=8"
set "quality9=9"
set "quality10=10 [Worst Quality]"
set /a count=1

REM Display quality options from 0 (best) to 10 (worst)
echo 1. [0] [Best Quality]
for /L %%q in (1,1,9) do (
    set /a option=%%q+1
    echo !option!. !quality%%q!
)
echo 11. [10] [Worst Quality]
echo 00. Disable this module
echo 0. Cancel
set /p audio_quality_choice="Your choice: "

REM Handle 'Cancel' and 'Disable' selection
if "!audio_quality_choice!"=="0" goto audio-editor-menu
if "!audio_quality_choice!"=="00" (
    set "audio_quality_trigger=false"
    call :save_audio_settings
    goto :audio-editor-menu
)

REM Set quality based on selection and enable the trigger
set /a idx=!audio_quality_choice!-1
if defined quality%idx% (
    set "audio_quality=!quality%idx%!"
    set "audio_quality_trigger=true"
    call :save_audio_settings
    goto :audio_editor_menu
) else (
    echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
    echo %red_bg%[%time%]%reset% Invalid input. Please enter a valid number.
    pause
    goto :audio_quality_menu
)

:audio_acodec_menu
title YT-DLP [SELECT AUDIO CODEC]
cls
echo %blue_fg_strong%/ Home / Editor / Edit Audio Modules / SELECT AUDIO CODEC%reset%
echo -------------------------------------------------------------

REM Define the available codecs
set "codecs=mp3 wav flac opus vorbis aac mp4a ac4"
set /a count=1

REM Display codec options
for %%a in (%codecs%) do (
    echo !count!. %%a
    set /a count+=1
)

echo %red_fg_strong%00. Disable this module%reset%
echo 0. Cancel
set /p audio_acodec_choice="Your choice: "

REM Handle 'Cancel' selection
if "!audio_acodec_choice!"=="0" (
    goto :audio-editor-menu
)

REM Handle 'Disable' selection
if "!audio_acodec_choice!"=="00" (
    set "audio_acodec_trigger=false"
    call :save_audio_settings
    goto :audio-editor-menu
)

REM Adjust index to map to codec list
set /a idx=!audio_acodec_choice! 
set /a validChoiceMax=count

REM Set codec based on selection and enable the trigger
if "!audio_acodec_choice!" geq "1" if "!audio_acodec_choice!" leq "!validChoiceMax!" (
    set /a acount=1
    for %%a in (%codecs%) do (
        if "!acount!"=="!idx!" (
            set "audio_acodec=%%a"
            set "audio_acodec_trigger=true" 
            call :save_audio_settings
            goto :audio-editor-menu
        )
        set /a acount+=1
    )
) else (
    echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
    echo %red_bg%[%time%]%reset% %echo_invalidinput%
    pause
    goto :audio_acodec_menu
)


REM ##################################################################################################################################################
REM ###########################################################  EDITOR VIDEO SUB-MODULES   ##########################################################
REM ##################################################################################################################################################

REM ############################################################
REM ############## EDIT VIDEO MODULES - FRONTEND ###############
REM ############################################################
    :edit_video_modules
    title YT-DLP [EDIT VIDEO MODULES]
    cls
    echo %blue_fg_strong%/ Home / Editor / Edit Video Modules%reset%
    echo -------------------------------------------------------------
    echo Choose Video modules to enable or disable

    REM Read modules-video and find the video_start_command line
    set "video_start_command="
    for /F "tokens=*" %%a in ('findstr /I "video_start_command=" "%video_modules_path%"') do (
        set "%%a"
    )
    set "video_start_command=!video_start_command:video_start_command=!"
    echo Preview: %cyan_fg_strong%!video_start_command!%reset%
    echo.

    REM Display module options with colors based on their status
    call :printModule "1. Sponsor Block (--sponsorblock-remove all)" !video_sponsorblock_trigger!
    call :printModule "2. Merge Output Format (--merge-output-format !mergeoutputformat!)" !video_mergeoutputformat_trigger!
    call :printModule "3. Resolution (-S res:!video_resolution!)" !video_resolution_trigger!
    call :printModule "4. Audio Codec (-S acodec:!video_acodec!)" !video_acodec_trigger!
    call :printModule "5. Video Codec (-S vcodec:!video_vcodec!)" !video_vcodec_trigger!
    call :printModule "6. Metadata (--embed-metadata --embed-chapters --embed-thumbnail)" !video_metadata_trigger!
    echo.
    echo 00. Quick Download Video
    echo 0. Back

    set /p video_module_choices="Choose modules to enable/disable: "

    for %%i in (!video_module_choices!) do (
        if "%%i"=="1" call :toggle_video_sponsorblock
        if "%%i"=="2" call :merge_output_format_menu
        if "%%i"=="3" call :video_resolution_menu
        if "%%i"=="4" call :video_audio_codec_menu
        if "%%i"=="5" call :video_codec_menu
        if "%%i"=="6" call :toggle_video_metadata
        if "%%i"=="00" goto :start_ytdlp_mp4
        if "%%i"=="0" goto :main_home_menu
    )

    goto :edit_video_modules

        :toggle_video_sponsorblock
        if "!video_sponsorblock_trigger!"=="true" (
            set "video_sponsorblock_trigger=false"
        ) else (
            set "video_sponsorblock_trigger=true"
        )
        call :save_video_settings
        goto :edit_video_modules


        :toggle_video_metadata
        if "!video_metadata_trigger!"=="true" (
            set "video_metadata_trigger=false"
        ) else (
            set "video_metadata_trigger=true"
        )
        call :save_video_settings
        goto :edit_video_modules





        REM ############## SELECT MERGE OUTPUT FORMAT - FRONTEND ###############
        :merge_output_format_menu
        title YT-DLP [SELECT MERGE OUTPUT FORMAT]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Video Modules / SELECT MERGE OUTPUT FORMAT%reset%
        echo -------------------------------------------------------------
        set "formats=mp4 flv mkv mov avi webm"
        REM This is the main count offset
        set /a count=1

        for %%f in (%formats%) do (
            echo !count!. %%f
            set /a count+=1
        )

        echo %red_fg_strong%00. Disable this module%reset%
        echo 0. Cancel
        set /p mergeoutputformat_choice="Your choice: "

        if "!mergeoutputformat_choice!"=="00" (
            set "video_mergeoutputformat_trigger=false"
            call :save_video_settings
            goto :edit_video_modules
        ) else if "!mergeoutputformat_choice!"=="0" (
            goto :edit_video_modules
        ) else if "!mergeoutputformat_choice!" geq "1" if "!mergeoutputformat_choice!" leq "6" (
            set "video_mergeoutputformat_trigger=true"
            set /a idx=!mergeoutputformat_choice! 
            set /a count=1
            for %%f in (%formats%) do (
                if "!count!"=="!idx!" (
                    set "mergeoutputformat=%%f"
                    call :save_video_settings
                    goto :edit_video_modules
                )
                set /a count+=1
            )
        ) 

        echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
        echo %red_bg%[%time%]%reset% %echo_invalidinput%
        pause
        goto :merge_output_format_menu



        REM ############## SELECT RESOLUTION - FRONTEND ###############
        :video_resolution_menu
        title YT-DLP [SELECT VIDEO RESOLUTION]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Video Modules / SELECT VIDEO RESOLUTION%reset%
        echo -------------------------------------------------------------
        set "resolutions=4320 2160 1440 1080 720 480 360 240 144"
        set /a count=1

        for %%r in (%resolutions%) do (
            if "%%r"=="4320" (
                echo !count!. %%rp 8K
            ) else if "%%r"=="2160" (
                echo !count!. %%rp 4K
            ) else if "%%r"=="1440" (
                echo !count!. %%rp HD
            ) else if "%%r"=="1080" (
                echo !count!. %%rp HD
            ) else (
                echo !count!. %%rp
            )
            set /a count+=1
        )

        echo %red_fg_strong%00. Disable this module%reset%
        echo 0. Cancel
        set /p video_resolution_choice="Your choice: "

        if "!video_resolution_choice!"=="0" (
            goto :edit_video_modules
        ) else if "!video_resolution_choice!"=="00" (
            set "video_resolution_trigger=false"
            call :save_video_settings
            goto :edit_video_modules
        ) else (
            set /a idx=video_resolution_choice 
            set /a count=1
            for %%r in (%resolutions%) do (
                if "!count!"=="!idx!" (
                    set "video_resolution_trigger=true"
                    set "video_resolution=%%r"
                    call :save_video_settings
                    goto :edit_video_modules
                )
                set /a count+=1
            )
        )

        echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
        echo %red_bg%[%time%]%reset% %echo_invalidinput%
        pause
        goto :video_resolution_menu

        REM ############## SELECT AUDIO CODEC - FRONTEND ###############
        :video_audio_codec_menu
        title YT-DLP [SELECT AUDIO CODEC]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Video Modules / SELECT AUDIO CODEC%reset%
        echo -------------------------------------------------------------
        set "codecs=mp3 wav flac opus vorbis aac mp4a ac4"
        
        set /a count=1

        for %%c in (%codecs%) do (
            echo !count!. %%c
            set /a count+=1
        )
        echo %red_fg_strong%00. Disable this module%reset%
        echo 0. Cancel
        set /p video_acodec_choice="Your choice: "

        if "!video_acodec_choice!"=="0" (
            goto :edit_video_modules
        ) else if "!video_acodec_choice!"=="00" (
            set "video_acodec_trigger=false"
            call :save_video_settings
            goto :edit_video_modules
        ) else (
            set /a idx=!video_acodec_choice! 
            set /a count=1
            for %%c in (%codecs%) do (
                if "!count!"=="!idx!" (
                    set "video_acodec_trigger=true"
                    set "video_acodec=%%c"
                    call :save_video_settings
                    goto :edit_video_modules
                )
                set /a count+=1
            )
        )

        echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
        echo %red_bg%[%time%]%reset% %echo_invalidinput%
        pause
        goto :video_audio_codec_menu


        :video_codec_menu
        title YT-DLP [SELECT VIDEO CODEC]
        cls
        echo %blue_fg_strong%/ Home / Editor / Edit Video Modules / SELECT VIDEO CODEC%reset%
        echo -------------------------------------------------------------

        REM Define the available codecs
        set "codecs=h264 h265 h263 av01 vp9.2 vp9 vp8 theora"
        set /a count=1

        REM Display codec options
        for %%v in (%codecs%) do (
            echo !count!. %%v
            set /a count+=1
        )

        echo %red_fg_strong%00. Disable this module%reset%
        echo 0. Cancel
        set /p video_vcodec_choice="Your choice: "

        REM Handle 'Cancel' selection
        if "!video_vcodec_choice!"=="0" (
            goto :edit_video_modules
        )

        REM Handle 'Disable' selection
        if "!video_vcodec_choice!"=="00" (
            set "video_vcodec_trigger=false"
            call :save_video_settings
            goto :edit_video_modules
        )

        REM Adjust index to map to codec list
        set /a idx=!video_vcodec_choice! 
        set /a validChoiceMax=!count! 

        REM Set codec based on selection and enable the trigger
        if "!video_vcodec_choice!" geq "1" if "!video_vcodec_choice!" leq "!validChoiceMax!" (
            set /a vcount=1
            for %%v in (%codecs%) do (
                if "!vcount!"=="!idx!" (
                    set "video_vcodec=%%v"
                    set "video_vcodec_trigger=true"
                    call :save_video_settings
                    goto :edit_video_modules
                )
                set /a vcount+=1
            )
        ) else (
            echo [%DATE% %TIME%] %log_invalidinput% >> %log_path%
            echo %red_bg%[%time%]%reset% %echo_invalidinput%
            pause
            goto :video_codec_menu
        )


        :save_video_module_choice
        REM Save the module flags to modules-video
        echo video_sponsorblock_trigger=%video_sponsorblock_trigger%>%video_modules_path%
        echo video_mergeoutputformat_trigger=%video_mergeoutputformat_trigger%>>%video_modules_path%
        echo video_resolution_trigger=%video_resolution_trigger%>>%video_modules_path%
        echo video_acodec_trigger=%video_acodec_trigger%>>%video_modules_path%
        echo video_vcodec_trigger=%video_vcodec_trigger%>>%video_modules_path%
        echo video_metadata_trigger=%video_metadata_trigger%>>%video_modules_path%
        echo video_start_command=%video_command%>>%video_modules_path%

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

REM ##################################################################################################################################################
REM ##################################################   UPDATE AND UNISTALL MODULES   ###############################################################
REM ##################################################################################################################################################

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

REM ##################################################################################################################################################
REM ##################################################   SAVE MODULES SETTINGS TO FILE   #############################################################
REM ##################################################################################################################################################

REM Function to save audio settings
:save_audio_settings
REM Compile the Python command based on current settings
set "audio_command= "
if "!audio_sponsorblock_trigger!"=="true" (
    set "audio_command=!audio_command! --sponsorblock-remove all"
)
if "!audio_format_trigger!"=="true" (
    set "audio_command=!audio_command! --audio-format !audio_format!"
)
if "!audio_quality_trigger!"=="true" (
    set "audio_command=!audio_command! --audio-quality !audio_quality!"
)
if "!audio_acodec_trigger!"=="true" (
    set "audio_command=!audio_command! -S acodec:!audio_acodec!"
)
if "!audio_metadata_trigger!"=="true" (
    set "audio_command=!audio_command! --embed-metadata --embed-chapters --embed-thumbnail"
)
if "!audio_verbose_trigger!"=="true" (
    set "audio_command=!audio_command! --verbose"
)

REM Save all audio settings including the start command to modules-audio
(
    echo audio_sponsorblock_trigger=!audio_sponsorblock_trigger!
    echo audio_format_trigger=!audio_format_trigger!
    echo audio_format=!audio_format!
    echo audio_quality_trigger=!audio_quality_trigger!
    echo audio_quality=!audio_quality!
    echo audio_acodec_trigger=!audio_acodec_trigger!
    echo audio_acodec=!audio_acodec!
    echo audio_metadata_trigger=!audio_metadata_trigger!
    echo audio_verbose_trigger=!audio_verbose_trigger!
    echo audio_start_command=!audio_command!
) > "%audio_modules_path%"

REM Function to save video settings
:save_video_settings
REM Compile the Python command based on current settings
set "video_command= "
if "!video_sponsorblock_trigger!"=="true" (
    set "video_command=!video_command! --sponsorblock-remove all"
)
if "!video_mergeoutputformat_trigger!"=="true" (
    set "video_command=!video_command! --merge-output-format !mergeoutputformat!"
)
if "!video_resolution_trigger!"=="true" (
    set "video_command=!video_command! -S res:!video_resolution!"
)
if "!video_acodec_trigger!"=="true" (
    set "video_command=!video_command! -S acodec:!video_acodec!"
)
if "!video_vcodec_trigger!"=="true" (
    set "video_command=!video_command! -S vcodec:!video_vcodec!"
)
if "!video_metadata_trigger!"=="true" (
    set "video_command=!video_command! --embed-metadata --embed-chapters --embed-thumbnail"
)

REM Save all video settings including the start command to modules-video
(
    echo video_sponsorblock_trigger=!video_sponsorblock_trigger!
    echo video_mergeoutputformat_trigger=!video_mergeoutputformat_trigger!
    echo mergeoutputformat=!mergeoutputformat!
    echo video_resolution_trigger=!video_resolution_trigger!
    echo video_resolution=!video_resolution!
    echo video_acodec_trigger=!video_acodec_trigger!
    echo video_acodec=!video_acodec!
    echo video_vcodec_trigger=!video_vcodec_trigger!
    echo video_vcodec=!video_vcodec!
    echo video_metadata_trigger=!video_metadata_trigger!
    echo video_start_command=!video_command!
) > "%video_modules_path%"
