#!/usr/bin/bash
#
# LLaVA Launcher
# Created by: Deffcolony
#
# Description:
# This script installs LLaVA to your Linux system.
#
# Usage:
# chmod +x llava-launcher.sh && ./llava-launcher.sh
#
# In automated environments, you may want to run as root.
# If using curl, we recommend using the -fsSL flags.
#
# This script is intended for use on Linux systems. Please
# report any issues or bugs on the GitHub repository.
#
# App Github: https://github.com/haotian-liu/LLaVA.git
#
# GitHub: https://github.com/deffcolony/ai-toolbox
# Issues: https://github.com/deffcolony/ai-toolbox/issues
# ----------------------------------------------------------
# Note: Modify the script as needed to fit your requirements.
# ----------------------------------------------------------

echo -e "\033]0;LLaVA Launcher\007"

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
green_bg="\033[42m"
yellow_bg="\033[0;103m"


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


# Function to install LLaVA
install_llava() {
    echo -e "\033]0;LLaVA [INSTALL]\007"
    clear
    echo -e "${blue_fg_strong}/ Home / Install LLaVA ${reset}"
    echo "---------------------------------------------------------------"
    echo -e "${cyan_fg_strong}This may take a while. Please be patient.${reset}"

    log_message "INFO" "Installing LLaVA..."
    git clone https://github.com/haotian-liu/LLaVA.git
    cd LLaVA

    log_message "INFO" "Downloading Miniconda installer script..."
    wget https://repo.anaconda.com/miniconda/$miniconda_installer -P /tmp
    chmod +x /tmp/$miniconda_installer

    log_message "INFO" "Running Miniconda installer script..."
    bash /tmp/$miniconda_installer -b -u -p $miniconda_path

    log_message "INFO" "Updating PATH to include Miniconda..."
    export PATH="$miniconda_path/bin:$PATH"

    log_message "INFO" "Activating Conda environment..."
    source $miniconda_path/etc/profile.d/conda.sh

    log_message "INFO" "Creating and activating the Conda environment..."
    conda config --set auto_activate_base false
    conda init bash
    conda create -n llava python=3.10 -y
    conda activate llava

    log_message "INFO" "Upgrading pip..."
    pip install --upgrade pip

    log_message "INFO" "Installing pip requirements..."
    pip install -e .
    pip install torch
    pip install ninja
    # Add more pip installations as needed

    log_message "INFO" "Cleaning up downloaded files..."
    rm -rf /tmp/$miniconda_installer

    log_message "INFO" "${green_fg_strong}LLaVA installed successfully.${reset}"
    read -p "Press Enter to continue..."
    home
}



# Function to run LLaVA
run_llava() {
    log_message "INFO" "Running LLaVA..."

    clear
    cd LLaVA

    log_message "INFO" "Activating Conda environment..."
    source $miniconda_path/etc/profile.d/conda.sh
    conda activate llava

    log_message "INFO" "Starting LLaVA controller..."
    python -m llava.serve.controller --host 0.0.0.0 --port 10000

    log_message "INFO" "Starting LLaVA model worker..."
    python -m llava.serve.model_worker --host 0.0.0.0 --controller http://localhost:10000 --port 40000 --worker http://localhost:40000 --model-path liuhaotian/llava-v1.5-13b

    log_message "INFO" "Setting up Gradio server..."
    export GRADIO_SERVER_NAME="0.0.0.0"
    export GRADIO_SERVER_PORT="3000"
    python -m llava.serve.gradio_web_server --controller http://localhost:10000 --model-list-mode reload

    log_message "INFO" "LLaVA is now running."
    home
}


# Function to update LLaVA
update_llava() {
    echo -e "\033]0;LLaVA [UPDATE]\007"
    clear
    echo -e "${blue_fg_strong}/ Home / Update${reset}"
    echo "---------------------------------------------------------------"

    cd LLaVA
    log_message "INFO" "Updating LLaVA..."
    git pull

    log_message "INFO" "Uninstalling the 'transformers' package..."
    pip uninstall transformers

    log_message "INFO" "upgrading pip requirements..."
    pip install -e .

    log_message "INFO" "${green_fg_strong}LLaVA has been updated successfully.${reset}"
    read -p "Press Enter to continue..."
    home
}


# Function to delete LLaVA
uninstall_llava() {
    echo -e "\033]0;LLaVA [UNINSTALL]\007"
    script_name=$(basename "$0")
    excluded_folders="backups"
    excluded_files="$script_name"

    # Confirm with the user before proceeding
    echo
    echo -e "${red_bg}╔════ DANGER ZONE ══════════════════════════════════════════════════════════════╗${reset}"
    echo -e "${red_bg}║ WARNING: This will delete all data of LLaVA                                   ║${reset}"
    echo -e "${red_bg}║ If you want to keep any data, make sure to create a backup before proceeding. ║${reset}"
    echo -e "${red_bg}╚═══════════════════════════════════════════════════════════════════════════════╝${reset}"
    echo
    read -p "Are you sure you want to proceed? [Y/N] " confirmation
    if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
        log_message "INFO" "Removing the LLaVA directory..."
        rm -rf LLaVA

        log_message "INFO" "Removing the Conda environment 'llava'..."
        conda remove --name llava --all -y

        log_message "INFO" "${green_fg_strong}LLaVA uninstalled successfully.${reset}"
        read -p "Press Enter to continue..."
        home
    else
        log_message "INFO" "Uninstall canceled."
        read -p "Press Enter to continue..."
        home
    fi
}

# Function for the installer menu
home() {
    echo -e "\033]0;LLaVA [HOME]\007"
    clear
    echo -e "${blue_fg_strong}/ Home${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Install LLaVA"
    echo "2. Run LLaVA"
    echo "3. Update"
    echo "4. Uninstall LLaVA"
    echo "5. Exit"

    read -p "Choose Your Destiny (default is 1): " choice

    # Default to choice 1 if no input is provided
    if [ -z "$choice" ]; then
      choice=1
    fi

    # home - Backend
    if [ "$choice" = "1" ]; then
        install_llava
    elif [ "$choice" = "2" ]; then
        run_llava
    elif [ "$choice" = "3" ]; then
        update_llava
    elif [ "$choice" = "4" ]; then
        uninstall_llava
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
    log_message "ERROR" "${red_fg_strong}Unsupported package manager. Cannot detect Linux distribution.${reset}"
    exit 1
fi
