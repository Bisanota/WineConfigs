#!/bin/bash

echo "Installing Wine and requirements"
sudo pacman -S --noconfirm --needed zenity lib32-libpulse lib32-alsa-plugins lib32-openal gst-plugins-bad gst-plugins-good
sudo pacman -S --noconfirm --needed wine winetricks wine-mono wine-gecko
sleep 1
clear

echo "Starting initial Wine config"
sleep 1
wineboot
clear

echo "Installing with winetricks some requeriments for CSP and FL Studio"
winetricks -q -f corefonts allcodecs wmp10 vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2022 vcrun6sp6 vcrun6 vkd3d msxml4 msxml6 mfc40 mf42 dotnet20sp1 dxvk d3dx9 d3dx10
sleep 1

echo "Installing files for CSP"
sudo cp release/x86_64-windows/*.dll /usr/lib/wine/x86_64-windows/
sudo cp release/x86_64-unix/*.so /usr/lib/wine/x86_64-unix/

echo "Finishing"
sleep 2
echo "Once you've installed CSP and FL Studio"
echo "Remember to put CSP on Windows 8.1, and general config in Windows 10"
sleep 1
echo "Thanks for use this script :)"
