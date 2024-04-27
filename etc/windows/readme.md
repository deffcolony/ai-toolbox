# Windows ADK Launcher
This script simplifies the process of installing and creating images with the Windows ADK. Whether you're deploying Windows in a corporate environment or tinkering with system setups, this tool streamlines the process for you.

# ⏳Installation
## 🪟 Windows
1.  On your keyboard: press **`WINDOWS + R`** to open Run dialog box. Then, run the following command to install git:
```shell
cmd /c winget install -e --id Git.Git
```
2. On your keyboard: press **`WINDOWS + E`** to open File Explorer, then navigate to the folder where you want to install. Once in the desired folder, type `cmd` into the address bar and press enter. Then, run the following command:
```shell
git clone https://github.com/deffcolony/ai-toolbox.git && cd ai-toolbox\etc\windows && start adk-launcher.bat
```

# 🔧 Getting Started
1. Once the adk-launcher.bat is launched press 1 to Install Windows ADK

2. **Prepare startnet.cmd**: Edit the `startnet.cmd` file included in this repository to match your specific setup requirements. This file defines the actions executed when WinPE starts. Customize it according to your preferences and deployment needs.

3. **Customize Unattend.xml (Optional)**: If you opt for a custom Unattend.xml configuration, generate or modify the XML file to reflect your deployment settings. Refer to the provided link for a user-friendly tool to assist you in creating this file.

* https://schneegans.de/windows/unattend-generator/

## 📝 Additional Notes
- **Custom Unattend.xml**: If you want to customize your installation process, you can create your own Unattend.xml file. For convenience, you can use tools like [Schneegans' Unattend Generator](https://schneegans.de/windows/unattend-generator/) to create tailored XML configurations.

- **Custom Background Image**: To add a personal touch to your installation environment, you can include a custom background image. Simply place a JPG image named `winpe.jpg` in the directory `C:\WinPE_amd64\mount\windows\system32\`.
