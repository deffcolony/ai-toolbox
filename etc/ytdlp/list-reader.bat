@echo off
setlocal EnableDelayedExpansion

echo Created by: AlexVeeBeee
echo.
echo Credits: 
echo - Deffcolony - 
echo -- https://github.com/deffcolony/ai-toolbox
echo.


set "output_file=%~dp0output.txt"


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


REM Settings
set "audio_modules_path=%~dp0yt-dlp-downloads\settings\modules-audio.txt"
set "audio_modules_path_exists=0"
set "video_modules_path=%~dp0yt-dlp-downloads\settings\modules-video.txt"
set "video_modules_path_exists=0"

if exist "%audio_modules_path%" (
    set "audio_modules_path_exists=1"
)

if exist "%video_modules_path%" (
    set "video_modules_path_exists=1"
)

if "%audio_modules_path_exists%"=="1" (
    for /F "tokens=*" %%a in ('findstr /I "audio_start_command=" "%audio_modules_path%"') do (
        set "%%a"
    )
    echo Loaded audio settings from %audio_modules_path%
)

if "%video_modules_path_exists%"=="1" (
    for /F "tokens=*" %%a in ('findstr /I "video_start_command=" "%video_modules_path%"') do (
        set "%%a"
    )
    echo Loaded video settings from %video_modules_path%
)


REM List file
set "list_file=%~dp0list.txt"

REM Check if the list file exists
if not exist "%list_file%" (
    echo List file not found.
    pause
    exit /b
)

REM Count the number of lines in the list file
for /f %%a in ('type "%list_file%" ^| find /c /v ""') do set "line_count=%%a"

title YT-DLP Downloader
echo Number of lines in the list file: %line_count%
echo Choose the download type (audio or video)
echo ----------------------------------------
echo 1. Audio
echo 2. Video
echo 0. Exit

REM Choose the download type
set /p download_type=Enter the download type (1, 2, 0):

if "%download_type%"=="1" (
    set "download_type=audio"
    if "%audio_modules_path_exists%"=="0" (
        echo Audio settings not found. Configure audio settings first.
        pause
        exit /b
    )
) else if "%download_type%"=="2" (
    set "download_type=video"
    if "%audio_modules_path_exists%"=="0" (
        echo Video settings not found. Configure video settings first.
        pause
        exit /b
    )
) else if "%download_type%"=="0" (
    exit /b
) else (
    echo Invalid input.
    pause
    exit /b
)

echo Download type: %download_type%

@REM check for errors
@REM echo %weburl% | findstr /R /C:"^https*://" /C:"^www\." > nul
@REM if errorlevel 1 (
@REM     echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Invalid input. Please enter a valid URL.%reset%
@REM     echo %red_fg_strong%URL must start with one of the following: http://, https://, or www.%reset%
@REM     pause
@REM     goto :start_ytdlp_mp3
@REM )

@REM loop
@REM https://music.youtube.com/watch?v=JO9h1fQU_-k

for /f "tokens=*" %%a in ('type "%list_file%"') do (
    set "weburl=%%a"
    echo URL: !weburl!

    @REM check for errors

    echo !weburl! | findstr /R /C:"^https*://" /C:"^www\." > nul
    if errorlevel 1 (
        echo Invalid input. Please enter a valid URL.
        echo URL must start with one of the following: http://, https://, or www.
        pause
        exit /b
    )

    echo Downloading !download_type! from !weburl!
    if "%download_type%"=="audio" (
        "%ytdlp_download_path%" -P "%ytdlp_audio_path%" %audio_start_command% -f ba/b -x -o "%%(title)s.%%(ext)s" -w !weburl!
    )

    echo.
)

echo Done.


pause