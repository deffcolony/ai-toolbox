@echo off
setlocal enabledelayedexpansion
title VibeVoice Launcher

REM ==========================================
REM ANSI Escape Code for Colors
REM ==========================================
set "reset=[0m"
set "white_fg_strong=[90m"
set "red_fg_strong=[91m"
set "green_fg_strong=[92m"
set "yellow_fg_strong=[93m"
set "blue_fg_strong=[94m"
set "magenta_fg_strong=[95m"
set "cyan_fg_strong=[96m"
set "red_bg=[41m"
set "blue_bg=[44m"
set "yellow_bg=[43m"

REM ==========================================
REM Paths and Variables
REM ==========================================
set "root_dir=%~dp0"
set "voice_generation_dir=%root_dir%voice-generation"
set "install_path=%voice_generation_dir%\VibeVoice"
set "settings_path=%voice_generation_dir%\settings"
set "modules_path=%settings_path%\vibevoice_modules.txt"

REM Ensure Directories Exist
if not exist "%voice_generation_dir%" mkdir "%voice_generation_dir%"
if not exist "%settings_path%" mkdir "%settings_path%"

REM Create modules file if it doesn't exist
if not exist "%modules_path%" (
    echo vibevoice_model_7b_trigger=false> "%modules_path%"
    echo vibevoice_streaming_trigger=false>> "%modules_path%"
    echo vibevoice_share_trigger=false>> "%modules_path%"
    echo vibevoice_disable_cloning_trigger=false>> "%modules_path%"
    echo vibevoice_checkpoint_path=none>> "%modules_path%"
    echo vibevoice_api_port=7985>> "%modules_path%"
)

REM Load Settings
if exist "%modules_path%" (
    for /F "tokens=*" %%a in ('type "%modules_path%"') do set "%%a"
)

cd /d "%root_dir%"

REM ==========================================
REM HOME MENU
REM ==========================================
:home
title VibeVoice [HOME]
cls

echo %blue_fg_strong%^| ^> / Home                                                     ^|%reset%
echo %blue_fg_strong% ==============================================================%reset%
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| What would you like to do?                                   ^|%reset%
echo    1. Start VibeVoice (Web UI)
echo    2. Start API Server (For SillyTavern)
echo    3. Install / Repair Environment
echo    4. Editor (Config)
echo    5. Toolbox
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Menu Options:                                                ^|%reset%
echo    0. Exit

echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^|                                                              ^|%reset%

REM Define a variable containing a single backspace character
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set "BS=%%A"

REM Set the prompt with spaces
set /p "choice=%BS%   Choose Your Destiny: "

if "%choice%"=="1" goto :start_vibevoice
if "%choice%"=="2" goto :start_api
if "%choice%"=="3" goto :install_vibevoice
if "%choice%"=="4" goto :edit_vibevoice_modules
if "%choice%"=="5" goto :toolbox
if "%choice%"=="0" exit

echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Invalid input.%reset%
pause
goto :home

REM ==========================================
REM 1. START VIBEVOICE UI
REM ==========================================
:start_vibevoice
title VibeVoice [RUNNING UI]
if not exist "%install_path%\.pixi" (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Environment not found. Please run Option 3 first!%reset%
    pause
    goto :home
)

cd /d "%install_path%"
for /F "tokens=*" %%a in ('type "%modules_path%"') do set "%%a"

REM Determine Model Path
if "!vibevoice_streaming_trigger!"=="true" (
    set "MODEL_ARG=microsoft/VibeVoice-Realtime-0.5B"
) else (
    if "!vibevoice_model_7b_trigger!"=="true" (
        set "MODEL_ARG=vibevoice/VibeVoice-7B"
    ) else (
        set "MODEL_ARG=vibevoice/VibeVoice-1.5B"
    )
)

set "vv_command=pixi run python demo/gradio_demo.py --model_path !MODEL_ARG!"
if "!vibevoice_share_trigger!"=="true" set "vv_command=!vv_command! --share"
if "!vibevoice_disable_cloning_trigger!"=="true" set "vv_command=!vv_command! --disable_prefill"
if not "!vibevoice_checkpoint_path!"=="none" set "vv_command=!vv_command! --checkpoint_path "!vibevoice_checkpoint_path!""

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Launching Gradio UI...
echo Model: %green_fg_strong%!MODEL_ARG!%reset%
start cmd /k "title VibeVoice UI && cd /d %install_path% && !vv_command!"
goto :home

REM ==========================================
REM 2. START API SERVER
REM ==========================================
:start_api
title VibeVoice [API]
if not exist "%install_path%\.pixi" (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Environment not found.%reset%
    pause
    goto :home
)

cd /d "%install_path%"
for /F "tokens=*" %%a in ('type "%modules_path%"') do set "%%a"

REM Determine Model Path
if "!vibevoice_streaming_trigger!"=="true" (
    set "MODEL_ARG=microsoft/VibeVoice-Realtime-0.5B"
) else (
    if "!vibevoice_model_7b_trigger!"=="true" (
        set "MODEL_ARG=vibevoice/VibeVoice-7B"
    ) else (
        set "MODEL_ARG=vibevoice/VibeVoice-1.5B"
    )
)

set "api_command=pixi run python tts_server.py --port !vibevoice_api_port! --model_path !MODEL_ARG!"

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Launching API Server on Port !vibevoice_api_port!...
echo Model: %green_fg_strong%!MODEL_ARG!%reset%
start cmd /k "title VibeVoice API && cd /d %install_path% && !api_command!"
goto :home

REM ==========================================
REM 3. INSTALLER
REM ==========================================
:install_vibevoice
REM ... [SAME INSTALLER CODE] ...
title VibeVoice [INSTALL]
cls
echo %blue_fg_strong%^| ^> / Home / Install VibeVoice                                 ^|%reset%
echo %blue_fg_strong% ==============================================================%reset%
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| GPU Selection                                                ^|%reset%
echo    1. NVIDIA
echo    2. AMD
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Menu Options:                                                ^|%reset%
echo    0. Cancel
set /p "gpu_choice=%BS%   Choose Your GPU: "
if "%gpu_choice%"=="1" goto :install_process
if "%gpu_choice%"=="2" goto :install_process
if "%gpu_choice%"=="0" goto :home
goto :install_vibevoice

:install_process
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Preparing installation...
cd /d "%voice_generation_dir%"
if exist "VibeVoice" (
    echo %blue_fg_strong%[INFO] Updating Repository...%reset%
    cd VibeVoice
    git pull
) else (
    echo %blue_fg_strong%[INFO] Cloning Repository...%reset%
    git clone https://github.com/vibevoice-community/VibeVoice.git
    cd VibeVoice
)
where pixi >nul 2>nul
if %errorlevel% neq 0 (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Pixi...
    powershell -Command "iwr -useb https://pixi.sh/install.ps1 | iex"
    set "PATH=%LocalAppData%\pixi\bin;%PATH%"
)
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Writing configuration file...
if exist pixi.toml del pixi.toml
(
echo [build-system]
echo requires = ["setuptools>=61.0"]
echo build-backend = "setuptools.build_meta"
echo.
echo [project]
echo name = "vibevoice"
echo version = "0.0.1"
echo authors = [{ name="vibevoice team", email="vibepod@microsoft.com" }]
echo description = "VibeVoice Text-to-Speech"
echo readme = "README.md"
echo requires-python = "==3.11"
echo dependencies = [
echo     "torch",
echo     "accelerate==1.6.0",
echo     "transformers==4.51.3",
echo     "llvmlite>=0.40.0",
echo     "numba>=0.57.0",
echo     "diffusers",
echo     "tqdm",
echo     "numpy",
echo     "scipy",
echo     "librosa",
echo     "ml-collections",
echo     "absl-py",
echo     "gradio>=5.0,<6.0",
echo     "av",
echo     "aiortc",
echo     "setuptools>=80.9.0",
echo     "flash-attn",
echo     "triton-windows<3.4",
echo     "fastapi",
echo     "uvicorn",
echo     "python-multipart",
echo     "soundfile"
echo ]
echo.
echo [tool.setuptools.packages.find]
echo where = ["."]
echo.
echo [tool.uv.sources]
echo flash-attn = { path = "flash_attn-2.7.4+cu128torch2.7-cp311-cp311-win_amd64.whl" }
echo.
echo [tool.pixi.workspace]
echo channels = ["conda-forge"]
echo platforms = ["win-64"]
echo.
echo [tool.pixi.pypi-dependencies]
echo vibevoice = { path = ".", editable = true }
echo gradio = ">=5.0.0" 
echo torch = { version = "==2.7.1+cu128", index = "https://download.pytorch.org/whl/cu128" }
echo torchvision = { version = "==0.22.1+cu128", index = "https://download.pytorch.org/whl/cu128" }
echo torchaudio = { version = "==2.7.1+cu128", index = "https://download.pytorch.org/whl/cu128" }
echo.
echo [tool.pixi.dependencies]
echo python = "3.11.*"
echo uv = ">=0.9.11,<0.10"
echo git = ">=2.52.0,<3"
) > pyproject.toml
if not exist "flash_attn-2.7.4+cu128torch2.7-cp311-cp311-win_amd64.whl" (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading Flash Attention Wheel...
    curl -L -o "flash_attn-2.7.4+cu128torch2.7-cp311-cp311-win_amd64.whl" "https://huggingface.co/Jmica/flash_attention/resolve/main/flash_attn-2.7.4%%2Bcu128torch2.7-cp311-cp311-win_amd64.whl"
)
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing environment...
call pixi install
echo %green_fg_strong%Installation Complete.%reset%
pause
goto :home

REM ==========================================
REM 4. EDITOR
REM ==========================================
:edit_vibevoice_modules
title VibeVoice [EDITOR]
cls
echo %blue_fg_strong%^| ^> / Home / Editor                                              ^|%reset%
echo %blue_fg_strong% ==============================================================%reset%
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Configuration                                                ^|%reset%

if "!vibevoice_streaming_trigger!"=="true" (
    echo    1. Use 7B Model [--IGNORED, Streaming Active]
    echo    2. Use Streaming Model 0.5B [%green_fg_strong%Enabled%reset%]
) else (
    call :printModule "1. Use 7B Model (High Quality)" !vibevoice_model_7b_trigger!
    echo    2. Use Streaming Model 0.5B [%red_fg_strong%Disabled%reset%]
)

call :printModule "3. Public Share Link (Gradio)" !vibevoice_share_trigger!
call :printModule "4. Disable Voice Cloning (Prefill)" !vibevoice_disable_cloning_trigger!
echo    5. Set Checkpoint/LoRA Path [%green_fg_strong%!vibevoice_checkpoint_path!%reset%]
echo    6. Set API Port [%green_fg_strong%!vibevoice_api_port!%reset%]
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Menu Options:                                                ^|%reset%
echo    0. Back

echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^|                                                              ^|%reset%

REM Define a variable containing a single backspace character
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set "BS=%%A"

REM Set the prompt with spaces
set /p "vv_module_choices=%BS%   Choose modules to enable/disable: "

if "%vv_module_choices%"=="1" call :toggle_model_7b
if "%vv_module_choices%"=="2" call :toggle_streaming
if "%vv_module_choices%"=="3" call :toggle_share
if "%vv_module_choices%"=="4" call :toggle_cloning
if "%vv_module_choices%"=="5" call :set_checkpoint
if "%vv_module_choices%"=="6" call :set_port
if "%vv_module_choices%"=="0" goto :home

goto :edit_vibevoice_modules

REM --- Toggle Functions ---
:toggle_model_7b
if "!vibevoice_model_7b_trigger!"=="true" (set "vibevoice_model_7b_trigger=false") else (set "vibevoice_model_7b_trigger=true")
call :save_vibevoice_settings
exit /b

:toggle_streaming
if "!vibevoice_streaming_trigger!"=="true" (set "vibevoice_streaming_trigger=false") else (set "vibevoice_streaming_trigger=true")
call :save_vibevoice_settings
exit /b

:toggle_share
if "!vibevoice_share_trigger!"=="true" (set "vibevoice_share_trigger=false") else (set "vibevoice_share_trigger=true")
call :save_vibevoice_settings
exit /b

:toggle_cloning
if "!vibevoice_disable_cloning_trigger!"=="true" (set "vibevoice_disable_cloning_trigger=false") else (set "vibevoice_disable_cloning_trigger=true")
call :save_vibevoice_settings
exit /b

:set_checkpoint
echo.
echo %cyan_fg_strong%Enter full path to checkpoint file (or type 'none' to clear):%reset%
set /p user_ckpt="Path: "
if not "!user_ckpt!"=="" set "vibevoice_checkpoint_path=!user_ckpt!"
call :save_vibevoice_settings
exit /b

:set_port
echo.
echo %cyan_fg_strong%Enter API Port (Default 7985):%reset%
set /p user_port="Port: "
if not "!user_port!"=="" set "vibevoice_api_port=!user_port!"
call :save_vibevoice_settings
exit /b

:save_vibevoice_settings
(
    echo vibevoice_model_7b_trigger=!vibevoice_model_7b_trigger!
    echo vibevoice_streaming_trigger=!vibevoice_streaming_trigger!
    echo vibevoice_share_trigger=!vibevoice_share_trigger!
    echo vibevoice_disable_cloning_trigger=!vibevoice_disable_cloning_trigger!
    echo vibevoice_checkpoint_path=!vibevoice_checkpoint_path!
    echo vibevoice_api_port=!vibevoice_api_port!
) > "%modules_path%"
exit /b

REM ==========================================
REM TOOLBOX
REM ==========================================
:toolbox
title VibeVoice [TOOLBOX]
cls
echo %blue_fg_strong%^| ^> / Home / Toolbox                                             ^|%reset%
echo %blue_fg_strong% ==============================================================%reset%
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Utilities                                                    ^|%reset%
echo    1. Update VibeVoice
echo    2. Rebuild Pixi Environment
echo    3. Open Installation Folder
echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^| Menu Options:                                                ^|%reset%
echo    0. Back

echo %cyan_fg_strong% ______________________________________________________________%reset%
echo %cyan_fg_strong%^|                                                              ^|%reset%

REM Define a variable containing a single backspace character
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set "BS=%%A"

REM Set the prompt with spaces
set /p "choice=%BS%   Choose Your Destiny: "


if "%choice%"=="1" goto :toolbox_update
if "%choice%"=="2" goto :toolbox_rebuild
if "%choice%"=="3" goto :toolbox_open
if "%choice%"=="0" goto :home

goto :toolbox

:toolbox_update
cd /d "%install_path%"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating...
git pull
call pixi update
pause
goto :toolbox

:toolbox_rebuild
echo %red_bg%WARNING: This will delete the local environment folder (.pixi)%reset%
pause
if exist "%install_path%\.pixi" rmdir /s /q "%install_path%\.pixi"
goto :install_vibevoice

:toolbox_open
start "" "%install_path%"
goto :toolbox

REM ==========================================
REM HELPER FUNCTION (Print Module)
REM ==========================================
:printModule
set "module_text=%~1"
if "%2"=="true" (
    echo %green_fg_strong%!module_text! [Enabled]%reset%
) else (
    echo %red_fg_strong%!module_text! [Disabled]%reset%
)
exit /b