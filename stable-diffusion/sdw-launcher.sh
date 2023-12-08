#!/bin/bash
#
# Stable Diffusion web UI Launcher
# Created by: Deffcolony
#
# Description:
# This script installs Stable Diffusion web UI to your Linux system.
#
# Usage:
# chmod +x sdw-launcher.sh && ./sdw-launcher.sh
#
# In automated environments, you may want to run as root.
# If using curl, we recommend using the -fsSL flags.
#
# This script is intended for use on Linux systems. Please
# report any issues or bugs on the GitHub repository.
#
# App Github: https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
#
# GitHub: https://github.com/deffcolony/ai-toolbox
# Issues: https://github.com/deffcolony/ai-toolbox/issues
# ----------------------------------------------------------
# Note: Modify the script as needed to fit your requirements.
# ----------------------------------------------------------
echo -e "\033]0;Stable Difussion Web UI\007"

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


# Function to install Git
install_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${yellow_fg_strong}[WARN] Git is not installed on this system.${reset}"

        if command -v apt-get &>/dev/null; then
            # Debian/Ubuntu-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using apt..."
            sudo apt-get update
            sudo apt-get install -y git
        elif command -v yum &>/dev/null; then
            # Red Hat/Fedora-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using yum..."
            sudo yum install -y git
        elif command -v apk &>/dev/null; then
            # Alpine Linux-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using apk..."
            sudo apk add git
        elif command -v pacman &>/dev/null; then
            # Arch Linux-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using pacman..."
            sudo pacman -S --noconfirm git
        elif command -v emerge &>/dev/null; then
            # Gentoo Linux-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing Git using emerge..."
            sudo emerge --ask dev-vcs/git
        else
            echo -e "${red_fg_strong}[ERROR] Unsupported Linux distribution.${reset}"
            exit 1
        fi

        echo -e "${green_fg_strong}Git is installed.${reset}"
    else
        echo -e "${blue_fg_strong}[INFO] Git is already installed.${reset}"
    fi
}


# Function to install Stable Diffusion web UI
install_sdw() {
    echo -e "\033]0;SD Web UI [INSTALL-SDW]\007"
    clear
    echo -e "${blue_fg_strong}/ Home / Stable Diffusion web UI${reset}"
    echo "---------------------------------------------------------------"
    echo -e "${blue_fg_strong}[INFO]${reset} Installing Stable Diffusion web UI..."
    echo -e "${cyan_fg_strong}This may take a while. Please be patient.${reset}"

    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

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
    conda create -n stablediffusionwebui -y
    conda activate stablediffusionwebui
    conda install python=3.10.6 git -y

    # Cleanup the Downloaded file
    rm -rf /tmp/$miniconda_installer
    echo -e "${green_fg_strong}Stable Diffusion web UI installed successfully.${reset}"
    read -p "Press Enter to continue..."
    home
}



# Function to run Stable Diffusion web UI
run_sdw() {
    echo -e "\033]0;SD Web UI\007"
    clear
    cd stable-diffusion-webui
    source $miniconda_path/etc/profile.d/conda.sh
    conda activate stablediffusionwebui
    python ./launch.py
    home
}


# Function to run Stable Diffusion web UI with addons
run_sdw_addons() {
    echo -e "\033]0;SD Web UI [ADDONS]\007"
    clear
    cd stable-diffusion-webui
    source $miniconda_path/etc/profile.d/conda.sh
    conda activate stablediffusionwebui
    python ./launch.py --autolaunch --api --listen --port 7900 --xformers --reinstall-xformers --theme dark
    home
}


# Function to delete Stable Difussion Web UI
uninstall_sdw() {
    script_name=$(basename "$0")
    excluded_folders="backups"
    excluded_files="$script_name"

    # Confirm with the user before proceeding
    echo
    echo -e "${red_bg}╔════ DANGER ZONE ══════════════════════════════════════════════════════════════╗${reset}"
    echo -e "${red_bg}║ WARNING: This will delete all Stable Difussion Web UI data                    ║${reset}"
    echo -e "${red_bg}║ If you want to keep any data, make sure to create a backup before proceeding. ║${reset}"
    echo -e "${red_bg}╚═══════════════════════════════════════════════════════════════════════════════╝${reset}"
    echo
    read -p "Are you sure you want to proceed? [Y/N] " confirmation
    if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
        rm -rf stable-diffusion-webui
        conda remove --name stablediffusionwebui --all -y
    else
        echo "Action canceled."
    home
    fi
}

# Function for the home menu
home() {
    echo -e "\033]0;SD Web UI [HOME]\007"
    clear
    echo -e "${blue_fg_strong}/ Home${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Install Stable Diffusion web UI"
    echo "2. Run Stable Diffusion web UI"
    echo "3. Run Stable Diffusion web UI with addons"
    echo "4. Uninstall Stable Diffusion web UI"
    echo "0. Exit"

    read -p "Choose Your Destiny: " home_choice

    # Default to choice 1 if no input is provided
    if [ -z "$home_choice" ]; then
      home_choice=1
    fi

    # Home menu - Backend
    case $home_choice in
        1) install_sdw ;;
        2) run_sdw ;;
        3) run_sdw_addons ;;
        4) uninstall_sdw ;;
        0) exit ;;
        *) echo -e "${yellow_fg_strong}WARNING: Invalid number. Please insert a valid number.${reset}"
           read -p "Press Enter to continue..."
           home ;;
    esac
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

