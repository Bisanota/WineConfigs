#!/bin/bash
WEBVIEW2_URL="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/76eb3dc4-7851-45b7-a392-460523b0e2bb/MicrosoftEdgeWebView2RuntimeInstallerX64.exe"
THUMBNAILER_SRC="$PWD/release/clip-thumbnailer"
THUMBNAILER_BIN="$HOME/.local/bin/clip-thumbnailer"


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
winetricks -q -f corefonts allcodecs wmp10 vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2022 vcrun6sp6 vcrun6 vkd3d msxml4 msxml6 mfc40 mf42 dotnet20sp1 dxvk
winetricks -q -f d3dx9 d3dx10
sleep 1

echo "Installing files for CSP"
sudo cp release/x86_64-windows/*.dll /usr/lib/wine/x86_64-windows/
sudo cp release/x86_64-unix/*.so /usr/lib/wine/x86_64-unix/
wget $WEBVIEW2_URL
wine webview2installer.exe
install -Dm755 "$THUMBNAILER_SRC" "$THUMBNAILER_BIN"
    _MIME_DIR="$HOME/.local/share/mime"
    mkdir -p "$_MIME_DIR/packages"
    if [[ ! -f "$_MIME_DIR/packages/clip.xml" ]]; then
        cat > "$_MIME_DIR/packages/clip.xml" << 'MIMEEOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-clip">
    <comment>Clip Studio Paint file</comment>
    <glob pattern="*.clip"/>
  </mime-type>
</mime-info>
MIMEEOF
        update-mime-database "$_MIME_DIR" 2>/dev/null || true
fi


_THUMB_DIR="$HOME/.local/share/thumbnailers"
    mkdir -p "$_THUMB_DIR"
    if [[ ! -f "$_THUMB_DIR/clip.thumbnailer" ]]; then
        cat > "$_THUMB_DIR/clip.thumbnailer" << THUMBEOF
[Thumbnailer Entry]
TryExec=$THUMBNAILER_BIN
Exec=$THUMBNAILER_BIN %i %o
MimeType=application/x-clip;
THUMBEOF
    fi

fetch_asset() {
    local rel="$1" dest="$2"
    if [[ -f "$dest" && -s "$dest" ]]; then
        return 0
    fi
    [[ $DRY_RUN -eq 1 ]] && return 0
    mkdir -p "$(dirname "$dest")"
    info "fetching $rel"
    local tmp="${dest}.part"
    wget -q -O "$tmp" "$GH_RAW/$rel" || { rm -f "$tmp"; die "failed to download $rel"; }
    mv "$tmp" "$dest"
}

ensure_asset() {
    local rel="$1" dest="$2"
    if [[ ! -f "$dest" ]]; then
        fetch_asset "$rel" "$dest"
    fi
}

SYS32="$HOME/.wine/drive_c/windows/system32"


LAUNCHER_DIR="$HOME/.local/share/cspenguin"
DCOMP_DLL="release/dcomp/dcomp.dll"
    PTHREAD_DLL="release/dcomp/libwinpthread-1.dll"
    ensure_asset "release/dcomp/dcomp.dll"          "$DCOMP_DLL"
    ensure_asset "release/dcomp/libwinpthread-1.dll" "$PTHREAD_DLL"
    [[ -f "$DCOMP_DLL" ]]
mkdir "$LAUNCHER_DIR"
    cp "$DCOMP_DLL"    "$LAUNCHER_DIR/dcomp.dll"
    cp "$DCOMP_DLL"    "$SYS32/dcomp.dll"
    cp "$PTHREAD_DLL"  "$SYS32/libwinpthread-1.dll"
        
echo "Finishing"
sleep 2
echo "Once you've installed CSP and FL Studio"
echo "Remember to put CSP on Windows 8.1, and general config in Windows 10"
sleep 1
echo "Thanks for use this script :)"
