#!/usr/bin/bash
#
# LLaVA Installer Script v0.0.3
# Created by: Deffcolony
#
# Description:
# This script installs LLaVA to your Linux system.
#
# Usage:
# chmod +x sdw-install.sh && ./sdw-install.sh
#
# In automated environments, you may want to run as root.
# If using curl, we recommend using the -fsSL flags.
#
# This script is intended for use on Linux systems. Please
# report any issues or bugs on the GitHub repository.
#
# GitHub: https://github.com/deffcolony/ai-toolbox
# Issues: https://github.com/deffcolony/ai-toolbox/issues
# ----------------------------------------------------------
# Note: Modify the script as needed to fit your requirements.
# ----------------------------------------------------------

title="LLaVA [HOME]"

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


# Function to install LLaVA
install-llava() {
    clear
    echo -e "${blue_fg_strong}/ Home / Install LLaVA ${reset}"
    echo "---------------------------------------------------------------"
    echo -e "${blue_fg_strong}[INFO]${reset} Installing LLaVA..."
    echo -e "${cyan_fg_strong}This may take a while. Please be patient.${reset}"

    git clone https://github.com/haotian-liu/LLaVA.git

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
    conda create -n llava -y
    conda activate llava
    conda install python=3.10 git -y
    pip install --upgrade pip
    pip install torch
    pip install -e .
    pip install ninja
    pip install flash-attn --no-build-isolation

    # Cleanup the Downloaded file
    rm -rf /tmp/$miniconda_installer
    echo -e "${green_fg_strong}LLaVA installed successfully.${reset}"
    read -p "Press Enter to continue..."
    installer
}



# Function to run LLaVA
run-llava() {
    clear
    cd LLaVA
    source $miniconda_path/etc/profile.d/conda.sh
    conda activate llava
    python -m llava.serve.controller --host 0.0.0.0 --port 10000
    python -m llava.serve.model_worker --host 0.0.0.0 --controller http://localhost:10000 --port 40000 --worker http://localhost:40000 --model-path liuhaotian/llava-v1.5-13b
    export GRADIO_SERVER_NAME="0.0.0.0"
    export GRADIO_SERVER_PORT="3000"
    python -m llava.serve.gradio_web_server --controller http://localhost:10000 --model-list-mode reload
    installer
}



# Function to update LLaVA
update-llava() {
    clear
    echo -e "${blue_fg_strong}/ Home / Update${reset}"
    echo "---------------------------------------------------------------"
    echo -e "${blue_fg_strong}[INFO]${reset} Updating LLaVA..."
    echo -e "${cyan_fg_strong}This may take a while. Please be patient.${reset}"
    cd LLaVA
    git pull
    pip uninstall transformers
    pip install -e .
    installer
}



# Function for the installer menu
installer() {
    clear
    echo -e "${blue_fg_strong}/ Home${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Install LLaVA"
    echo "2. Run LLaVA"
    echo "3. Update"
    echo "4. Exit"

    read -p "Choose Your Destiny (default is 1): " choice

    # Default to choice 1 if no input is provided
    if [ -z "$choice" ]; then
      choice=1
    fi

    # Installer - Backend
    if [ "$choice" = "1" ]; then
        install-llava
    elif [ "$choice" = "2" ]; then
        run-llava
    elif [ "$choice" = "3" ]; then
        update-llava
    elif [ "$choice" = "4" ]; then
        exit
    else
        echo -e "${yellow_fg_strong}WARNING: Invalid number. Please insert a valid number.${reset}"
        read -p "Press Enter to continue..."
        installer
    fi
}

# Detect the package manager and execute the appropriate installation
if command -v apt-get &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Debian/Ubuntu-based system.${reset}"
    read -p "Press Enter to continue..."
    # Debian/Ubuntu
    install_git
    installer
elif command -v yum &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Red Hat/Fedora-based system.${reset}"
    # Red Hat/Fedora
    install_git
    installer
elif command -v apk &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Alpine Linux-based system.${reset}"
    # Alpine Linux
    install_git
    installer
elif command -v pacman &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Arch Linux-based system.${reset}"
    # Arch Linux
    install_git
    installer
elif command -v emerge &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Gentoo Linux-based system. Now you are the real CHAD${reset}"
    # Gentoo Linux
    install_git
    installer
else
    echo -e "${red_fg_strong}[ERROR] Unsupported package manager. Cannot detect Linux distribution.${reset}"
    exit 1
fi

