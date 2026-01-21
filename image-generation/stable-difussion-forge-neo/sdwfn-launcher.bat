@echo off
setlocal enabledelayedexpansion
title SDWFN Launcher [PRO]

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
REM Paths and Settings
REM ==========================================
set "install_path=%~dp0stable-diffusion-webui-forge-neo"
set "settings_file=%~dp0sdwfn-settings.txt"

REM Default Values if settings file doesn't exist
if not exist "%settings_file%" (
    echo sdwfn_uv_trigger=true> "%settings_file%"
    echo sdwfn_sage_trigger=true>> "%settings_file%"
    echo sdwfn_cudamalloc_trigger=true>> "%settings_file%"
    echo sdwfn_themedark_trigger=true>> "%settings_file%"
    echo sdwfn_autolaunch_trigger=false>> "%settings_file%"
    echo sdwfn_api_trigger=false>> "%settings_file%"
    echo sdwfn_port_trigger=false>> "%settings_file%"
    echo sdwfn_listen_trigger=false>> "%settings_file%"
    echo sdwfn_xformers_trigger=false>> "%settings_file%"
    echo sdwfn_flash_trigger=false>> "%settings_file%"
    echo sdwfn_highvram_trigger=false>> "%settings_file%"
    echo sdwfn_lowvram_trigger=false>> "%settings_file%"
    echo sdwfn_bnb_trigger=false>> "%settings_file%"
)

:load_settings
for /f "tokens=1,* delims==" %%A in ('type "%settings_file%"') do set "%%A=%%B"

:home
title SDWFN [HOME]
cls
echo %cyan_fg_strong% Stable Diffusion WebUI Forge - NEO Launcher %reset%
echo --------------------------------------------------------------------------------
echo    1. Start Forge-NEO
echo    2. Install / Repair Environment 
echo    3. Edit Launch Arguments
echo    4. Install Models
echo    5. Update Forge-NEO
echo    6. Toolbox
echo    0. Exit
echo --------------------------------------------------------------------------------
set /p choice="Choose Your Destiny: "

if "%choice%"=="1" goto :start_neo
if "%choice%"=="2" goto :install_neo
if "%choice%"=="3" goto :editor
if "%choice%"=="4" goto :models
if "%choice%"=="5" goto :update_neo
if "%choice%"=="6" goto :toolbox
if "%choice%"=="0" exit
goto :home

:start_neo
if not exist "%install_path%\.pixi" (
    echo %red_bg%[ERROR] Environment not found. Please run Option 2 first!%reset%
    pause
    goto :home
)
cd /d "%install_path%"
echo %blue_bg%[%time%]%reset% Initializing WebUI with saved arguments...

set "py_cmd=pixi run python launch.py"
if "%sdwfn_uv_trigger%"=="true" set "py_cmd=%py_cmd% --uv"
if "%sdwfn_sage_trigger%"=="true" set "py_cmd=%py_cmd% --sage"
if "%sdwfn_flash_trigger%"=="true" set "py_cmd=%py_cmd% --flash"
if "%sdwfn_xformers_trigger%"=="true" set "py_cmd=%py_cmd% --xformers"
if "%sdwfn_cudamalloc_trigger%"=="true" set "py_cmd=%py_cmd% --cuda-malloc"
if "%sdwfn_highvram_trigger%"=="true" set "py_cmd=%py_cmd% --always-high-vram"
if "%sdwfn_lowvram_trigger%"=="true" set "py_cmd=%py_cmd% --always-low-vram"
if "%sdwfn_bnb_trigger%"=="true" set "py_cmd=%py_cmd% --bnb"
if "%sdwfn_autolaunch_trigger%"=="true" set "py_cmd=%py_cmd% --autolaunch"
if "%sdwfn_api_trigger%"=="true" set "py_cmd=%py_cmd% --api"
if "%sdwfn_listen_trigger%"=="true" set "py_cmd=%py_cmd% --listen"
if "%sdwfn_port_trigger%"=="true" set "py_cmd=%py_cmd% --port 7900"
if "%sdwfn_themedark_trigger%"=="true" set "py_cmd=%py_cmd% --theme dark"

%py_cmd%
pause
goto :home

:install_neo
title SDWFN [INSTALLER]
echo %blue_fg_strong%[INFO] Fixing Long Paths and Cloning...%reset%
call git config --global core.longpaths true
if not exist "%install_path%" (
    call git clone -b neo https://github.com/Haoming02/sd-webui-forge-classic.git "%install_path%"
) else (
    cd /d "%install_path%"
    call git pull
)

cd /d "%install_path%"
(
echo [workspace]
echo name = "forge-neo"
echo channels = ["conda-forge", "pytorch", "nvidia"]
echo platforms = ["win-64"]
echo.
echo [dependencies]
echo python = "3.11.9.*"
echo uv = "*"
) > pixi.toml

call pixi install
echo %green_fg_strong%[SUCCESS] Environment is ready.%reset%
pause
goto :home

:editor
title SDWFN [EDITOR]
cls
echo %blue_fg_strong%=========================================================================%reset%
echo %cyan_fg_strong% Performance (NVIDIA / CUDA) %reset%
call :printMod "1.  Use UV (Recommended)    " %sdwfn_uv_trigger%
call :printMod "2.  Xformers Attention      " %sdwfn_xformers_trigger%
call :printMod "3.  Sage Attention (Neo)    " %sdwfn_sage_trigger%
call :printMod "4.  Flash Attention (Neo)   " %sdwfn_flash_trigger%
call :printMod "5.  CUDA Malloc (Optimized) " %sdwfn_cudamalloc_trigger%

echo %cyan_fg_strong% VRAM / Memory Management %reset%
call :printMod "6.  Always High VRAM        " %sdwfn_highvram_trigger%
call :printMod "7.  Always Low VRAM         " %sdwfn_lowvram_trigger%
call :printMod "8.  BitsAndBytes (4-bit)    " %sdwfn_bnb_trigger%

echo %cyan_fg_strong% Server ^& UI %reset%
call :printMod "9.  Auto-Launch Browser     " %sdwfn_autolaunch_trigger%
call :printMod "10. Enable API              " %sdwfn_api_trigger%
call :printMod "11. Listen (LAN Access)     " %sdwfn_listen_trigger%
call :printMod "12. Custom Port (7900)      " %sdwfn_port_trigger%
call :printMod "13. Theme: Dark             " %sdwfn_themedark_trigger%

echo --------------------------------------------------------------------------------
echo    00. Save and Start Forge NEO   ^|   0. Back
echo --------------------------------------------------------------------------------
set /p echoice="Toggle Option(s): "

for %%i in (%echoice%) do (
    if "%%i"=="1" ( if "!sdwfn_uv_trigger!"=="true" (set "sdwfn_uv_trigger=false") else (set "sdwfn_uv_trigger=true") )
    if "%%i"=="2" ( if "!sdwfn_xformers_trigger!"=="true" (set "sdwfn_xformers_trigger=false") else (set "sdwfn_xformers_trigger=true") )
    if "%%i"=="3" ( if "!sdwfn_sage_trigger!"=="true" (set "sdwfn_sage_trigger=false") else (set "sdwfn_sage_trigger=true") )
    if "%%i"=="4" ( if "!sdwfn_flash_trigger!"=="true" (set "sdwfn_flash_trigger=false") else (set "sdwfn_flash_trigger=true") )
    if "%%i"=="5" ( if "!sdwfn_cudamalloc_trigger!"=="true" (set "sdwfn_cudamalloc_trigger=false") else (set "sdwfn_cudamalloc_trigger=true") )
    if "%%i"=="6" ( if "!sdwfn_highvram_trigger!"=="true" (set "sdwfn_highvram_trigger=false") else (set "sdwfn_highvram_trigger=true") )
    if "%%i"=="7" ( if "!sdwfn_lowvram_trigger!"=="true" (set "sdwfn_lowvram_trigger=false") else (set "sdwfn_lowvram_trigger=true") )
    if "%%i"=="8" ( if "!sdwfn_bnb_trigger!"=="true" (set "sdwfn_bnb_trigger=false") else (set "sdwfn_bnb_trigger=true") )
    if "%%i"=="9" ( if "!sdwfn_autolaunch_trigger!"=="true" (set "sdwfn_autolaunch_trigger=false") else (set "sdwfn_autolaunch_trigger=true") )
    if "%%i"=="10" ( if "!sdwfn_api_trigger!"=="true" (set "sdwfn_api_trigger=false") else (set "sdwfn_api_trigger=true") )
    if "%%i"=="11" ( if "!sdwfn_listen_trigger!"=="true" (set "sdwfn_listen_trigger=false") else (set "sdwfn_listen_trigger=true") )
    if "%%i"=="12" ( if "!sdwfn_port_trigger!"=="true" (set "sdwfn_port_trigger=false") else (set "sdwfn_port_trigger=true") )
    if "%%i"=="13" ( if "!sdwfn_themedark_trigger!"=="true" (set "sdwfn_themedark_trigger=false") else (set "sdwfn_themedark_trigger=true") )
    if "%%i"=="00" ( goto :save_editor && goto :start_neo )
    if "%%i"=="0" ( goto :home )
)
:save_editor
(
echo sdwfn_uv_trigger=%sdwfn_uv_trigger%
echo sdwfn_xformers_trigger=%sdwfn_xformers_trigger%
echo sdwfn_sage_trigger=%sdwfn_sage_trigger%
echo sdwfn_flash_trigger=%sdwfn_flash_trigger%
echo sdwfn_cudamalloc_trigger=%sdwfn_cudamalloc_trigger%
echo sdwfn_highvram_trigger=%sdwfn_highvram_trigger%
echo sdwfn_lowvram_trigger=%sdwfn_lowvram_trigger%
echo sdwfn_bnb_trigger=%sdwfn_bnb_trigger%
echo sdwfn_autolaunch_trigger=%sdwfn_autolaunch_trigger%
echo sdwfn_api_trigger=%sdwfn_api_trigger%
echo sdwfn_listen_trigger=%sdwfn_listen_trigger%
echo sdwfn_port_trigger=%sdwfn_port_trigger%
echo sdwfn_themedark_trigger=%sdwfn_themedark_trigger%
) > "%settings_file%"
goto :editor

:models
title SDWFN [MODELS]
cls
echo %blue_fg_strong%=========================================================================%reset%
echo %cyan_fg_strong% 1. Pony Diffusion V6 XL    2. AutismMix SDXL             %reset%
echo %cyan_fg_strong% 3. CyberRealistic Pony     4. Hassaku XL (Illustrious)   %reset%
echo %cyan_fg_strong% 5. Flux.1 Dev (NF4)        6. Flux.1 Schnell (NF4)       %reset%
echo %cyan_fg_strong% 7. Custom Model (By ID)    0. Back                       %reset%
echo %blue_fg_strong%=========================================================================%reset%
set /p mchoice="Select Model: "
if "%mchoice%"=="0" goto :home
cd /d "%install_path%"
if "%mchoice%"=="1" call pixi run civitdl 257749 -s basic "models\Stable-diffusion"
if "%mchoice%"=="2" call pixi run civitdl 288584 -s basic "models\Stable-diffusion"
if "%mchoice%"=="3" call pixi run civitdl 443821 -s basic "models\Stable-diffusion"
if "%mchoice%"=="4" call pixi run civitdl 140272 -s basic "models\Stable-diffusion"
if "%mchoice%"=="5" call pixi run civitdl 638187 -s basic "models\Stable-diffusion"
if "%mchoice%"=="6" call pixi run civitdl 638187 -s basic "models\Stable-diffusion"
if "%mchoice%"=="7" (
    set /p mid="Enter CivitAI Model ID: "
    call pixi run civitdl !mid! -s basic "models\Stable-diffusion"
)
pause
goto :models

:update_neo
cd /d "%install_path%"
call git pull
call pixi update
pause
goto :home

:toolbox
title SDWFN [TOOLBOX]
set "theme_text=Install Lobe Theme"
if exist "%install_path%\extensions\sd-webui-lobe-theme" set "theme_text=%red_fg_strong%Uninstall Lobe Theme%reset%"
cls
echo    1. %theme_text%
echo    2. Rebuild Pixi Environment (Safe)
echo    3. %cyan_fg_strong%Symlink Models Folder (External Drive)%reset%
echo    4. %red_bg%UNINSTALL Forge-NEO%reset%
echo    0. Back
set /p tchoice="Select: "
if "%tchoice%"=="1" goto :toggle_theme
if "%tchoice%"=="2" (
    rmdir /s /q "%install_path%\.pixi"
    goto :install_neo
)
if "%tchoice%"=="3" goto :symlink_models
if "%tchoice%"=="4" goto :uninstall
goto :home

:toggle_theme
if exist "%install_path%\extensions\sd-webui-lobe-theme" (
    rmdir /s /q "%install_path%\extensions\sd-webui-lobe-theme"
) else (
    cd /d "%install_path%\extensions"
    git clone https://github.com/PeterBai923/sd-webui-lobe-theme
)
goto :toolbox

:symlink_models
title SDWFN [SYMLINK MODELS]
cls
echo %blue_fg_strong%[INFO] Select the folder where your models ARE ACTUALLY LOCATED.%reset%
echo %white_fg_strong%(e.g., D:\AI_Assets\Models)%reset%
echo.

REM PowerShell Folder Picker
set "ps_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select External Models Folder'; if($f.ShowDialog() -eq 'OK') { $f.SelectedPath }"
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "%ps_cmd%"`) do set "target_path=%%i"

if not defined target_path (
    echo %red_fg_strong%Selection canceled.%reset%
    pause
    goto :toolbox
)

echo %blue_bg%[%time%]%reset% Target: %cyan_fg_strong%%target_path%%reset%
echo %blue_bg%[%time%]%reset% Linking to: %white_fg_strong%%install_path%\models%reset%

REM Check if the models directory in the repo is a real folder or a link
if exist "%install_path%\models" (
    fsutil reparsepoint query "%install_path%\models" >nul 2>&1
    if !errorlevel! equ 0 (
        echo %yellow_fg_strong%[WARN] Existing link detected. Removing old link...%reset%
        rmdir "%install_path%\models"
    ) else (
        echo %yellow_fg_strong%[WARN] Real folder detected. Renaming to backup...%reset%
        ren "%install_path%\models" "models_OLD_%DATE:/=-%_%TIME::=-%"
    )
)

mklink /j "%install_path%\models" "%target_path%"

if !errorlevel! equ 0 (
    echo %green_fg_strong%[SUCCESS] Junction created successfully!%reset%
) else (
    echo %red_bg%[ERROR] Failed to create symlink. Try running the launcher as Administrator.%reset%
)
pause
goto :toolbox

:uninstall
echo.
echo %red_bg% WARNING: THIS WILL DELETE ALL FORGE-NEO DATA! %reset%
set /p uconf="Type Y to confirm: "
if /i "%uconf%"=="Y" (
    cd /d "%~dp0"
    rmdir /s /q "%install_path%"
    echo Uninstalled.
    pause
)
goto :home

:printMod
if "%2"=="true" (echo    %1 [%green_fg_strong%Enabled%reset%]) else (echo    %1 [%red_fg_strong%Disabled%reset%])
exit /b