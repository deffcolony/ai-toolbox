#!/bin/bash
#
# textgen web UI
# Created by: Deffcolony
#
# Description:
# This script installs Text generation web UI to your Linux system.
#
# Usage:
# chmod +x textgen-launcher.sh && ./textgen-launcher.sh 
#
# In automated environments, you may want to run as root.
# If using curl, we recommend using the -fsSL flags.
#
# This script is intended for use on Linux systems. Please
# report any issues or bugs on the GitHub repository.
#
# App Github: https://github.com/oobabooga/text-generation-webui.git
#
# GitHub: https://github.com/deffcolony/ai-toolbox
# Issues: https://github.com/deffcolony/ai-toolbox/issues
# ----------------------------------------------------------
# Note: Modify the script as needed to fit your requirements.
# ----------------------------------------------------------
echo -e "\033]0;Text generation web UI\007"

# ANSI Escape Code for Colors
reset="\033[0m"
white_fg_strong="\033[90m" 
red_fg_strong="\033[91m"
green_fg_strong="\033[92m"
yellow_fg_strong="\033[93m"
blue_fg_strong="\033[94m"
magenta_fg_strong="\033[95m"
cyan_fg_strong="\033[96m"

# Normal Background Colors
red_bg="\033[41m"
blue_bg="\033[44m"

# Environment Variables (TOOLBOX Install Extras)
miniconda_path="$HOME/miniconda"
miniconda_installer="Miniconda3-latest-Linux-x86_64.sh"

# Function to log messages with timestamps and colors
log_message() {
    # This is only time
    current_time=$(date +'%H:%M:%S')
    # This is with date and time 
    # current_time=$(date +'%Y-%m-%d %H:%M:%S')
    case "$1" in
        "INFO")
            echo -e "${blue_bg}[$current_time]${reset} ${blue_fg_strong}[INFO]${reset} $2"
            ;;
        "WARN")
            echo -e "${yellow_bg}[$current_time]${reset} ${yellow_fg_strong}[WARN]${reset} $2"
            ;;
        "ERROR")
            echo -e "${red_bg}[$current_time]${reset} ${red_fg_strong}[ERROR]${reset} $2"
            ;;
        *)
            echo -e "${blue_bg}[$current_time]${reset} ${blue_fg_strong}[DEBUG]${reset} $2"
            ;;
    esac
}

# Log your messages test window
#log_message "INFO" "Something has been launched."
#log_message "WARN" "${yellow_fg_strong}Something is not installed on this system.${reset}"
#log_message "ERROR" "${red_fg_strong}An error occurred during the process.${reset}"
#log_message "DEBUG" "This is a debug message."
#read -p "Press Enter to continue..."

# Function to install Git
install_git() {
    if ! command -v git &> /dev/null; then
        log_message "WARN" "${yellow_fg_strong}Git is not installed on this system${reset}"

        if command -v apt-get &>/dev/null; then
            # Debian/Ubuntu-based system
            log_message "INFO" "Installing Git using apt..."
            sudo apt-get update
            sudo apt-get install -y git
        elif command -v yum &>/dev/null; then
            # Red Hat/Fedora-based system
            log_message "INFO" "Installing Git using yum..."
            sudo yum install -y git
        elif command -v apk &>/dev/null; then
            # Alpine Linux-based system
            log_message "INFO" "Installing Git using apk..."
            sudo apk add git
        elif command -v pacman &>/dev/null; then
            # Arch Linux-based system
            log_message "INFO" "Installing Git using pacman..."
            sudo pacman -S --noconfirm git
        elif command -v emerge &>/dev/null; then
            # Gentoo Linux-based system
            log_message "INFO" "Installing Git using emerge..."
            sudo emerge --ask dev-vcs/git
        else
            log_message "ERROR" "${red_fg_strong}Unsupported Linux distribution.${reset}"
            exit 1
        fi

        log_message "INFO" "${green_fg_strong}Git is installed.${reset}"
    else
        echo -e "${blue_fg_strong}[INFO] Git is already installed.${reset}"
    fi
}


# Function to install Text generation web UI
install_textgen() {
    echo -e "\033]0;textgen [INSTALL]\007"
    clear
    echo -e "${blue_fg_strong}/ Home / textgen${reset}"
    echo "---------------------------------------------------------------"
    echo -e "${cyan_fg_strong}This may take a while. Please be patient.${reset}"
    log_message "INFO" "Installing Text generation web UI..."

    git clone https://github.com/oobabooga/text-generation-webui.git

    # Download the Miniconda installer script
    wget https://repo.anaconda.com/miniconda/$miniconda_installer -P /tmp
    chmod +x /tmp/$miniconda_installer

    # Run the installer script
    bash /tmp/$miniconda_installer -b -u -p $miniconda_path

    # Update PATH to include Miniconda
    export PATH="$miniconda_path/bin:$PATH"

    # Activate Conda environment
    source $miniconda_path/etc/profile.d/conda.sh

    # Create and activate the Conda environment
    conda config --set auto_activate_base false
    conda init bash
    conda create -n textgen -y
    conda activate textgen
    conda install python=3.10 git -y

    cd /d "$PWD/text-generation-webui/extensions/openai"

    log_message "INFO" "Installing openai extension and xformers..."
    pip install -r requirements.txt
    pip install xformers

    # Cleanup the Downloaded file
    rm -rf /tmp/$miniconda_installer
    log_message "INFO" "${green_fg_strong}Text generation web UI installed successfully.${reset}"
    read -p "Press Enter to continue..."
    home
}



# Function to run Text generation web UI
run_textgen() {
    echo -e "\033]0;textgen\007"
    clear
    echo -e "${blue_fg_strong}/ Home / Run textgen${reset}"
    echo "---------------------------------------------------------------"

    cd "$PWD/text-generation-webui"

    # config for portable miniconda
    INSTALL_DIR="$(pwd)/installer_files"
    CONDA_ROOT_PREFIX="$(pwd)/installer_files/conda"
    INSTALL_ENV_DIR="$(pwd)/installer_files/env"

    # environment isolation for portable miniconda
    export PYTHONNOUSERSITE=1
    unset PYTHONPATH
    unset PYTHONHOME
    export CUDA_PATH="$INSTALL_ENV_DIR"
    export CUDA_HOME="$CUDA_PATH"

    # check if conda environment was actually created
    if [ ! -e "$INSTALL_ENV_DIR/bin/python" ]; then
        echo "Conda environment is empty."
        exit
    fi

    source "$CONDA_ROOT_PREFIX/etc/profile.d/conda.sh"
    conda activate "$INSTALL_ENV_DIR"
    pip install xformers
    conda deactivate "$INSTALL_ENV_DIR"

    source $miniconda_path/etc/profile.d/conda.sh
    conda activate textgen

    # Start textgen with desired configurations
    log_message "INFO" "textgen launched in a new window."
    cd "$PWD/text-generation-webui"

    # Start a seperate terminal emulator (adjust the command as needed)
    #x-terminal-emulator -e "cd $(dirname "$0")./text-generation-webui && python ./one_click.py "$@" --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --xformers" &
    python ./one_click.py "$@" --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --xformers
    home
}


# Function to run Text generation web UI with addons
run_textgen_addons() {
    echo -e "\033]0;textgen [ADDONS]\007"
    clear
    echo -e "${blue_fg_strong}/ Home / Run textgen + addons${reset}"
    echo "---------------------------------------------------------------"

    cd "$PWD/text-generation-webui"

    # config for portable miniconda
    INSTALL_DIR="$(pwd)/installer_files"
    CONDA_ROOT_PREFIX="$(pwd)/installer_files/conda"
    INSTALL_ENV_DIR="$(pwd)/installer_files/env"

    # environment isolation for portable miniconda
    export PYTHONNOUSERSITE=1
    unset PYTHONPATH
    unset PYTHONHOME
    export CUDA_PATH="$INSTALL_ENV_DIR"
    export CUDA_HOME="$CUDA_PATH"

    # check if conda environment was actually created
    if [ ! -e "$INSTALL_ENV_DIR/bin/python" ]; then
        echo "Conda environment is empty."
        exit
    fi

    source "$CONDA_ROOT_PREFIX/etc/profile.d/conda.sh"
    conda activate "$INSTALL_ENV_DIR"
    pip install xformers
    conda deactivate "$INSTALL_ENV_DIR"

    source $miniconda_path/etc/profile.d/conda.sh
    conda activate textgen

    # Start textgen with desired configurations
    log_message "INFO" "textgen launched in a new window."
    cd "$PWD/text-generation-webui"

    # Start a seperate terminal emulator (adjust the command as needed)
    #x-terminal-emulator -e "cd $(dirname "$0")./text-generation-webui && python ./one_click.py "$@" --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --model TheBloke_MythoMax-L2-13B-GPTQ --xformers
    python ./one_click.py "$@" --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --model TheBloke_MythoMax-L2-13B-GPTQ --xformers
    home
}


# Function to delete textgen
uninstall_textgen() {
    script_name=$(basename "$0")
    excluded_folders="backups"
    excluded_files="$script_name"

    # Confirm with the user before proceeding
    echo
    echo -e "${red_bg}╔════ DANGER ZONE ══════════════════════════════════════════════════════════════╗${reset}"
    echo -e "${red_bg}║ WARNING: This will delete all Text generation web UI data                     ║${reset}"
    echo -e "${red_bg}║ If you want to keep any data, make sure to create a backup before proceeding. ║${reset}"
    echo -e "${red_bg}╚═══════════════════════════════════════════════════════════════════════════════╝${reset}"
    echo
    read -p "Are you sure you want to proceed? [Y/N] " confirmation
    if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
        rm -rf textgen
        conda remove --name textgen --all -y
    else
        echo "Action canceled."
    home
    fi
}

# Function for the home menu
home() {
    echo -e "\033]0;Textgen Web UI [HOME]\007"
    clear
    echo -e "${blue_fg_strong}/ Home${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Install textgen"
    echo "2. Run textgen"
    echo "3. Run textgen + addons"
    echo "4. Uninstall textgen"
    echo "5. Exit"

    read -p "Choose Your Destiny (default is 1): " choice

    # Default to choice 1 if no input is provided
    if [ -z "$choice" ]; then
      choice=1
    fi

    # Home - Backend
    if [ "$choice" = "1" ]; then
        install_textgen
    elif [ "$choice" = "2" ]; then
        run_textgen
    elif [ "$choice" = "3" ]; then
        run_textgen_addons
    elif [ "$choice" = "4" ]; then
        uninstall_textgen
    elif [ "$choice" = "5" ]; then
        exit
    else
        echo -e "${yellow_fg_strong}WARNING: Invalid number. Please insert a valid number.${reset}"
        read -p "Press Enter to continue..."
        home
    fi
}

# Detect the package manager and execute the appropriate installation
if command -v apt-get &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Debian/Ubuntu-based system.${reset}"
    # Debian/Ubuntu
    install_git
    home
elif command -v yum &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Red Hat/Fedora-based system.${reset}"
    # Red Hat/Fedora
    install_git
    home
elif command -v apk &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Alpine Linux-based system.${reset}"
    # Alpine Linux
    install_git
    home
elif command -v pacman &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Arch Linux-based system.${reset}"
    # Arch Linux
    install_git
    home
elif command -v emerge &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Gentoo Linux-based system. Now you are the real CHAD${reset}"
    # Gentoo Linux
    install_git
    home
else
    echo -e "${red_fg_strong}[ERROR] Unsupported package manager. Cannot detect Linux distribution.${reset}"
    exit 1
fi

