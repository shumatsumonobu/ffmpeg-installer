#!/bin/sh
set -e

# ==============================================================================
# FFmpeg Installer
#
# Installs FFmpeg and its required encoder libraries from source.
# All libraries are built as static and installed to ~/ffmpeg_build.
# The ffmpeg binary is installed to ~/bin.
#
# Supported platforms:
#   - CentOS / RHEL (yum)
#   - Rocky Linux / AlmaLinux / Amazon Linux 2023 / Fedora (dnf)
#   - Ubuntu / Debian (apt)
#
# Installed encoders:
#   - x264  (H.264 video encoder)
#   - x265  (H.265/HEVC video encoder)
#   - fdk-aac (AAC audio encoder)
#   - LAME  (MP3 audio encoder)
#   - Opus  (Opus audio encoder)
#   - Ogg   (Ogg container format library)
#   - Vorbis (Vorbis audio encoder)
#   - VPX   (VP8/VP9 video encoder)
#   - AV1   (AV1 video encoder via libaom)
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
# ==============================================================================

# ------------------------------------------------------------------------------
# Detect OS and package manager
# ------------------------------------------------------------------------------
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID="$ID"
else
  echo "Error: Cannot detect OS (missing /etc/os-release)"
  exit 1
fi

case "$OS_ID" in
  centos|rhel)
    PKG_INSTALL="sudo yum -y install"
    PKG_REMOVE="sudo yum -y remove"
    PACKAGES="autoconf automake cmake freetype-devel gcc gcc-c++ git libtool make pkgconfig zlib-devel wget curl"
    ;;
  rocky|alma|amzn|fedora)
    PKG_INSTALL="sudo dnf -y --allowerasing install"
    PKG_REMOVE="sudo dnf -y remove"
    PACKAGES="autoconf automake cmake diffutils freetype-devel gcc gcc-c++ git libtool make pkgconfig zlib-devel wget curl xz"
    ;;
  ubuntu|debian)
    PKG_INSTALL="sudo apt-get -y install"
    PKG_REMOVE="sudo apt-get -y remove"
    PACKAGES="autoconf automake cmake libfreetype6-dev gcc g++ git libtool make pkg-config python3 zlib1g-dev wget curl xz-utils"
    ;;
  *)
    echo "Error: Unsupported OS '$OS_ID'"
    echo "Supported: centos, rhel, rocky, alma, amzn, fedora, ubuntu, debian"
    exit 1
    ;;
esac

echo "Detected OS: $OS_ID"

# ------------------------------------------------------------------------------
# [1/14] Install build dependencies
# ------------------------------------------------------------------------------
echo "==> [1/14] Installing build dependencies..."
$PKG_INSTALL $PACKAGES

# ------------------------------------------------------------------------------
# [2/14] Upgrade cmake if version is below 3.5 (required for building libaom)
# ------------------------------------------------------------------------------
cmake_version=$(cmake --version | head -1 | awk -F " " '{print $3}')
cmake_major_version=$(echo "$cmake_version" | cut -d. -f1)
cmake_minor_version=$(echo "$cmake_version" | cut -d. -f2)
if [ "$cmake_major_version" -lt 3 ] || { [ "$cmake_major_version" -eq 3 ] && [ "$cmake_minor_version" -lt 5 ]; }; then
  echo "==> [2/14] Upgrading cmake ($cmake_version -> 3.16.9)..."
  $PKG_REMOVE cmake
  cd ~
  wget https://cmake.org/files/v3.16/cmake-3.16.9.tar.gz
  tar -xvzf cmake-3.16.9.tar.gz
  cd cmake-3.16.9
  ./bootstrap
  make
  sudo make install
fi

# Ensure ~/bin is on PATH so that Yasm, NASM, and other tools built
# in earlier steps are found by configure scripts in later steps.
mkdir -p "$HOME/bin"
export PATH="$HOME/bin:$PATH"

# Create a working directory for downloading and building source files
mkdir -p ~/ffmpeg_sources

# ------------------------------------------------------------------------------
# [3/14] Install Yasm (assembler required by x264 and other encoders)
# ------------------------------------------------------------------------------
echo "==> [3/14] Installing Yasm..."
cd ~/ffmpeg_sources
git clone --depth 1 https://github.com/yasm/yasm.git
cd yasm
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install

# ------------------------------------------------------------------------------
# [4/14] Install NASM (assembler required by x264 and other encoders)
# ------------------------------------------------------------------------------
echo "==> [4/14] Installing NASM..."
cd ~/ffmpeg_sources
wget https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/nasm-2.16.03.tar.xz
tar xvfJ nasm-2.16.03.tar.xz
cd nasm-2.16.03
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install

# ------------------------------------------------------------------------------
# [5/14] Install x264 (H.264 video encoder)
# ------------------------------------------------------------------------------
echo "==> [5/14] Installing x264..."
cd ~/ffmpeg_sources
git clone --depth 1 https://code.videolan.org/videolan/x264.git
cd x264
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" \
  ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make
make install

# ------------------------------------------------------------------------------
# [6/14] Install x265 (H.265/HEVC video encoder)
# ------------------------------------------------------------------------------
echo "==> [6/14] Installing x265..."
cd ~/ffmpeg_sources
git clone https://bitbucket.org/multicoreware/x265_git.git
mkdir -p ~/ffmpeg_sources/x265_git/build/linux
cd ~/ffmpeg_sources/x265_git/build/linux
cmake -G "Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" \
  -DENABLE_SHARED=off \
  ../../source
make
make install

# ------------------------------------------------------------------------------
# [7/14] Install fdk-aac (Fraunhofer FDK AAC audio encoder)
# ------------------------------------------------------------------------------
echo "==> [7/14] Installing fdk-aac..."
cd ~/ffmpeg_sources
git clone --depth 1 https://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install

# ------------------------------------------------------------------------------
# [8/14] Install LAME (MP3 audio encoder)
# ------------------------------------------------------------------------------
echo "==> [8/14] Installing LAME..."
cd ~/ffmpeg_sources
curl -O -L https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
tar xzvf lame-3.100.tar.gz
cd lame-3.100
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
make
make install

# ------------------------------------------------------------------------------
# [9/14] Install Opus (low-latency audio encoder)
# ------------------------------------------------------------------------------
echo "==> [9/14] Installing Opus..."
cd ~/ffmpeg_sources
git clone https://gitlab.xiph.org/xiph/opus.git
cd opus
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install

# ------------------------------------------------------------------------------
# [10/14] Install libogg (Ogg container format library, required by Vorbis)
# ------------------------------------------------------------------------------
echo "==> [10/14] Installing libogg..."
cd ~/ffmpeg_sources
curl -O https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.5.tar.gz
tar xzvf libogg-1.3.5.tar.gz
cd libogg-1.3.5
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install

# ------------------------------------------------------------------------------
# [11/14] Install libvorbis (Vorbis audio encoder, depends on libogg)
# ------------------------------------------------------------------------------
echo "==> [11/14] Installing libvorbis..."
cd ~/ffmpeg_sources
curl -O https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-1.3.7.tar.gz
tar xzvf libvorbis-1.3.7.tar.gz
cd libvorbis-1.3.7
LDFLAGS="-L$HOME/ffmpeg_build/lib" CPPFLAGS="-I$HOME/ffmpeg_build/include" \
  ./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
make
make install

# ------------------------------------------------------------------------------
# [12/14] Install libvpx (VP8/VP9 video encoder)
# ------------------------------------------------------------------------------
echo "==> [12/14] Installing libvpx..."
cd ~/ffmpeg_sources
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples --as=nasm
make
make install

# ------------------------------------------------------------------------------
# [13/14] Install libaom (AV1 video encoder, requires cmake >= 3.5)
# ------------------------------------------------------------------------------
echo "==> [13/14] Installing libaom..."
cd ~/ffmpeg_sources
git clone --depth 1 https://aomedia.googlesource.com/aom
mkdir aom_build
cd aom_build
cmake -G "Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" \
  -DENABLE_SHARED=off \
  -DENABLE_NASM=on \
  ../aom
make
make install

# ------------------------------------------------------------------------------
# [14/14] Build and install FFmpeg with all encoder libraries enabled
# ------------------------------------------------------------------------------
echo "==> [14/14] Building FFmpeg..."
cd ~/ffmpeg_sources
git clone https://git.ffmpeg.org/ffmpeg.git
cd ffmpeg
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig:$HOME/ffmpeg_build/lib64/pkgconfig" \
  ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --bindir="$HOME/bin" \
    --pkg-config-flags="--static" \
    --enable-gpl \
    --enable-nonfree \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libaom \
    --extra-libs=-lpthread \
    --extra-libs=-lm
make
make install

# Refresh the shell's hash table so the new ffmpeg binary is recognized immediately
hash -r

echo ""
echo "Installation complete!"
"$HOME/bin/ffmpeg" -version
