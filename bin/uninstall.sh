#!/bin/sh

# ==============================================================================
# FFmpeg Uninstaller
#
# Uninstalls FFmpeg and its related encoder libraries that were installed
# by install.sh.
#
# Some libraries (nasm, x264, fdk-aac, libvpx, libaom) do not provide
# a "make uninstall" target. To fully remove them, manually delete the
# corresponding directories from ~/ffmpeg_sources and ~/ffmpeg_build.
#
# Usage:
#   chmod +x uninstall.sh
#   ./uninstall.sh
# ==============================================================================

# ------------------------------------------------------------------------------
# Uninstall Yasm (assembler)
# ------------------------------------------------------------------------------
cd ~/ffmpeg_sources/yasm && make uninstall

# ------------------------------------------------------------------------------
# Uninstall x265 (H.265/HEVC video encoder)
# ------------------------------------------------------------------------------
cd ~/ffmpeg_sources/x265_git/build/linux && make uninstall

# ------------------------------------------------------------------------------
# Uninstall LAME (MP3 audio encoder)
# ------------------------------------------------------------------------------
cd ~/ffmpeg_sources/lame-3.100 && make uninstall

# ------------------------------------------------------------------------------
# Uninstall Opus (audio encoder)
# ------------------------------------------------------------------------------
cd ~/ffmpeg_sources/opus && make uninstall

# ------------------------------------------------------------------------------
# Uninstall libogg (Ogg container format library)
# ------------------------------------------------------------------------------
cd ~/ffmpeg_sources/libogg-1.3.5 && make uninstall

# ------------------------------------------------------------------------------
# Uninstall libvorbis (Vorbis audio encoder)
# ------------------------------------------------------------------------------
cd ~/ffmpeg_sources/libvorbis-1.3.7 && make uninstall

# ------------------------------------------------------------------------------
# Uninstall FFmpeg
# ------------------------------------------------------------------------------
cd ~/ffmpeg_sources/ffmpeg && make uninstall

# ------------------------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------------------------
echo ""
echo "Uninstall complete."
echo ""
echo "To fully remove all build artifacts, run:"
echo "  rm -rf ~/ffmpeg_sources ~/ffmpeg_build ~/bin/ffmpeg ~/bin/ffprobe ~/bin/x264 ~/bin/lame ~/bin/nasm ~/bin/ndisasm ~/bin/yasm ~/bin/ytasm"
