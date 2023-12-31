#!/bin/bash
#
# Video Launcher
# Created by: Deffcolony
#
# Description:
# This script installs MPV player to your Linux system.
#
# Usage:
# chmod +x video-launcher.sh && ./video-launcher.sh
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

echo -e "\033]0;Video Launcher\007"

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


# Function to install MPV
install_mpv() {
    if ! command -v mpv &> /dev/null; then
        echo -e "${yellow_fg_strong}[WARN] MPV is not installed on this system.${reset}"

        if command -v apt-get &>/dev/null; then
            # Debian/Ubuntu-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing MPV using apt..."
            sudo apt update
            sudo apt install -y mpv
        elif command -v yum &>/dev/null; then
            # Red Hat/Fedora-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing MPV using dnf..."
            sudo dnf install -y mpv
        elif command -v zypper &>/dev/null; then
            # openSUSE-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing MPV using zypper..."
            sudo zypper install -y mpv
        elif command -v pacman &>/dev/null; then
            # Arch Linux-based system
            echo -e "${blue_fg_strong}[INFO]${reset} Installing MPV using pacman..."
            sudo pacman -S --noconfirm mpv
        else
            echo -e "${red_fg_strong}[ERROR] Unsupported Linux distribution.${reset}"
            exit 1
        fi

        echo -e "${green_fg_strong}MPV is installed.${reset}"
    else
        echo -e "${blue_fg_strong}[INFO] MPV is already installed.${reset}"
    fi
}

# Run Local
run_local() {
    echo -e "\033]0;Video Launcher [LOCAL]\007"
    clear
    echo -e "${blue_fg_strong}/ Home / Run Local Videos${reset}"
    echo "-------------------------------------"
    read -p "How many videos do you need: " numTimes

    # Check if the input is a valid number
    if ! [[ $numTimes =~ ^[0-9]+$ ]]; then
        echo -e "\033[1;33mPlease enter a valid number.\033[0m"
        read -n 1 -s -r -p "Press any key to continue..."
        run_local
    fi

    read -p "Enter filename of video (including extension): " videoFile

    for ((i=1; i<=$numTimes; i++)); do
        mpv "$videoFile"
    done

    home
}

# Run Online
run_online() {
    echo -e "\033]0;Video Launcher [ONLINE]\007"
    clear
    echo -e "${blue_fg_strong}/ Home / Run Online Videos${reset}"
    echo "-------------------------------------"
    read -p "How many browser tabs do you need: " numTimes

    # Check if the input is a valid number
    if ! [[ $numTimes =~ ^[0-9]+$ ]]; then
        echo -e "\033[1;33mPlease enter a valid number.\033[0m"
        read -n 1 -s -r -p "Press any key to continue..."
        run_online
    fi

    read -p "Enter YouTube link: " videoLink

    # Create a loop to open multiple tabs
    for ((i=1; i<=$numTimes; i++)); do
        xdg-open "$videoLink" >/dev/null 2>&1 &
    done

    home
}

# home Frontend
home() {
    echo -e "\033]0;Video Launcher [HOME]\007"
    clear
    echo -e "${blue_fg_strong}/ Home${reset}"
    echo "-------------------------------------"
    echo "What would you like to do?"
    echo "1. Run Local Videos"
    echo "2. Run Online Videos"
    echo "0. Exit"

    read -p "Choose Your Destiny: " home_choice

    # Default to choice 1 if no input is provided
    if [ -z "$home_choice" ]; then
      home_choice=1
    fi

    # Home menu - Backend
    case $home_choice in
        1) run_local ;;
        2) run_online ;;
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
    install_mpv
    home
elif command -v yum &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Red Hat/Fedora-based system.${reset}"
    # Red Hat/Fedora
    install_mpv
    home
elif command -v apk &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Alpine Linux-based system.${reset}"
    # Alpine Linux
    install_mpv
    home
elif command -v pacman &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Arch Linux-based system.${reset}"
    # Arch Linux
    install_mpv
    home
elif command -v emerge &>/dev/null; then
    echo -e "${blue_fg_strong}[INFO] Detected Gentoo Linux-based system. Now you are the real CHAD${reset}"
    # Gentoo Linux
    install_mpv
    home
else
    echo -e "${red_fg_strong}[ERROR] Unsupported package manager. Cannot detect Linux distribution.${reset}"
    exit 1
fi
