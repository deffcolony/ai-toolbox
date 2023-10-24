#!/usr/bin/bash
#
# textgen web UI
# Created by: Deffcolony
#
# Description:
# This script installs textgen web UI to your Linux system.
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


# Function to install textgen web UI
installtextgen() {
    echo -e "\033]0;textgen [INSTALL]\007"
    clear
    echo -e "${blue_fg_strong}/ Home / textgen web UI${reset}"
    echo "---------------------------------------------------------------"
    echo -e "${blue_fg_strong}[INFO]${reset} Installing textgen web UI..."
    echo -e "${cyan_fg_strong}This may take a while. Please be patient.${reset}"

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

    echo -e "${blue_fg_strong}[INFO]${reset} Installing openai extension and xformers..."
    pip install -r requirements.txt
    pip install xformers

    # Cleanup the Downloaded file
    rm -rf /tmp/$miniconda_installer
    echo -e "${green_fg_strong}textgen web UI installed successfully.${reset}"
    read -p "Press Enter to continue..."
    home
}



# Function to run textgen web UI
runtextgen() {
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
    echo -e %blue_fg_strong%[INFO]%reset% textgen has been launched.
    cd "$PWD/text-generation-webui"

    # Start a seperate terminal emulator (adjust the command as needed)
    #x-terminal-emulator -e "cd $(dirname "$0")./text-generation-webui && python ./one_click.py "$@" --api --listen --listen-port 7910 --loader ExLlama_HF --xformers" &
    python ./one_click.py "$@" --api --listen --listen-port 7910 --loader ExLlama_HF --xformers
    home
}


# Function to run textgen web UI with addons
runtextgenaddons() {
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
    echo -e %blue_fg_strong%[INFO]%reset% textgen has been launched.
    cd "$PWD/text-generation-webui"

    # Start a seperate terminal emulator (adjust the command as needed)
    #x-terminal-emulator -e "cd $(dirname "$0")./text-generation-webui && python ./one_click.py "$@" --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --model TheBloke_MythoMax-L2-13B-GPTQ --xformers
    python ./one_click.py "$@" --extensions openai --listen --listen-port 7910 --loader ExLlama_HF --model TheBloke_MythoMax-L2-13B-GPTQ --xformers
    home
}




# Function for the home menu
home() {
    echo -e "\033]0;Textgen Web UI [HOME]\007"
    clear
    echo -e "${blue_fg_strong}/ Home${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Install textgen web UI"
    echo "2. Run textgen web UI"
    echo "3. Run textgen web UI with addons"
    echo "4. Exit"

    read -p "Choose Your Destiny (default is 1): " choice

    # Default to choice 1 if no input is provided
    if [ -z "$choice" ]; then
      choice=1
    fi

    # Home - Backend
    if [ "$choice" = "1" ]; then
        installtextgen
    elif [ "$choice" = "2" ]; then
        runtextgen
    elif [ "$choice" = "3" ]; then
        runtextgenaddons
    elif [ "$choice" = "4" ]; then
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

