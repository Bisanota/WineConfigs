#!/bin/bash

WEBVIEW2_URL="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/76eb3dc4-7851-45b7-a392-460523b0e2bb/MicrosoftEdgeWebView2RuntimeInstallerX64.exe"
THUMBNAILER_SRC="$PWD/release/clip-thumbnailer"
THUMBNAILER_BIN="$HOME/.local/bin/clip-thumbnailer"

SYS32="$HOME/.wine/drive_c/windows/system32"
LAUNCHER_DIR="$HOME/.local/share/cspenguin"

echo "Installing Wine and requirements"
sudo pacman -S --noconfirm --needed zenity lib32-libpulse lib32-alsa-plugins lib32-openal gst-plugins-bad gst-plugins-good
sudo pacman -S --noconfirm --needed wine winetricks wine-mono wine-gecko
sleep 1
clear

echo "Starting initial Wine config"
sleep 1
wineboot
sleep 2
clear

echo "Installing winetricks requirements"
winetricks -q -f corefonts allcodecs wmp10 vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2022 vcrun6sp6 vcrun6 vkd3d msxml4 msxml6 mfc40 mf42 dotnet20sp1 dxvk
winetricks -q -f d3dx9 d3dx10
sleep 1

echo "Installing CSP patches and fixes"

mkdir -p "$SYS32"
mkdir -p "$LAUNCHER_DIR"

sudo cp release/x86_64-windows/*.dll /usr/lib/wine/x86_64-windows/
sudo cp release/x86_64-unix/*.so /usr/lib/wine/x86_64-unix/

wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "mfplat" /t REG_SZ /d "native,builtin" /f
wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "mfreadwrite" /t REG_SZ /d "native,builtin" /f

cp release/dcomp/dcomp.dll "$LAUNCHER_DIR/dcomp.dll"
cp release/dcomp/dcomp.dll "$SYS32/dcomp.dll"
cp release/dcomp/libwinpthread-1.dll "$SYS32/libwinpthread-1.dll"

wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v "dcomp" /t REG_SZ /d "native,builtin" /f


echo "Installing WebView2"
wget -q -O webview2.exe "$WEBVIEW2_URL"
WINEDEBUG=-all WINEDLLOVERRIDES="winemenubuilder.exe=d" wine webview2.exe
rm -f webview2.exe


wine reg add "HKCU\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f
wine reg add "HKCU\\Software\\Wine\\AppDefaults\\msedgewebview2.exe" /v Version /t REG_SZ /d "win7" /f
wine reg add "HKCU\\Software\\Wine\\AppDefaults\\CLIPStudioPaint.exe" /v Version /t REG_SZ /d "win81" /f
wine reg add "HKCU\\Software\\Wine\\AppDefaults\\CLIPStudio.exe" /v Version /t REG_SZ /d "win81" /f

echo "Setting up clip thumbnails"

install -Dm755 "$THUMBNAILER_SRC" "$THUMBNAILER_BIN"

MIME_DIR="$HOME/.local/share/mime"
mkdir -p "$MIME_DIR/packages"

cat > "$MIME_DIR/packages/clip.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-clip">
    <comment>Clip Studio Paint file</comment>
    <glob pattern="*.clip"/>
  </mime-type>
</mime-info>
EOF

update-mime-database "$MIME_DIR" 2>/dev/null || true

THUMB_DIR="$HOME/.local/share/thumbnailers"
mkdir -p "$THUMB_DIR"

cat > "$THUMB_DIR/clip.thumbnailer" << EOF
[Thumbnailer Entry]
TryExec=$THUMBNAILER_BIN
Exec=$THUMBNAILER_BIN %i %o
MimeType=application/x-clip;
EOF

echo "Finishing"
sleep 1
echo "Done :)"
