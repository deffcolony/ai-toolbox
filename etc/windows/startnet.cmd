@echo off
echo Welcome to WinPE Setup Script

echo Checking and bypassing specific setup checks...
for %%s in (sCPU sSecureBoot sTPM) do reg add HKLM\SYSTEM\Setup\LabConfig /f /v Bypass%%sCheck /d 1 /t reg_dword

echo Initializing Windows PE environment...
wpeinit

echo Connecting to network drive (Z:)...
net use Z: \\YOUR_NETBOOTXYZ_IP\WinPE

echo Starting setup with unattended XML...
z:\setup.exe /unattend:x:\unattend.xml