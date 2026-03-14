# Changelog

## [2.0.0] - 2026-03-14

A major overhaul — modernized every dependency URL, updated library versions, cleaned up the project structure, and made the installer actually pleasant to watch.

### Breaking Changes

Shell scripts and example files have been renamed:

| Before | After |
|--------|-------|
| `bin/ffmpeg-installer.sh` | `bin/install.sh` |
| `bin/ffmpeg-uninstaller.sh` | `bin/uninstall.sh` |
| `bin/test.sh` | Removed (logic already in install.sh) |
| `examples/nodejs/` | `examples/` (flattened) |
| `examples/convert-image-to-mp4.js` | `examples/images2mp4.js` |
| `examples/convert-image-to-gif.js` | `examples/images2gif.js` |

### Highlights

- **All repository URLs modernized** — replaced every deprecated `git://` and `http://` URL with `https://`. Switched x265 from Mercurial to Git. All clones now work out of the box
- **Library versions bumped** — NASM 2.14rc15 → 2.16.03, cmake 3.14.3 → 3.16.9, libogg 1.3.3 → 1.3.5, libvorbis 1.3.6 → 1.3.7
- **Live progress display** — the installer now prints `==> [1/14] Installing build dependencies...` through `[14/14] Building FFmpeg...` so you always know where it's at
- **Fail-fast with `set -e`** — install.sh now stops immediately on any error instead of silently continuing with a broken build
- **Cleaner examples** — rewrote Node.js samples with `for...of` + `await` instead of the old `map/reduce` promise chain. Reduced input images from 10 to 3
- **Install/uninstall flow diagrams** — Mermaid-generated PNG flowcharts in the README
- **New README** — banner image, shields.io badges, encoder table, command examples, and Node.js usage instructions
- **Multi-OS support** — auto-detects CentOS/RHEL (yum), Rocky Linux/AlmaLinux/Amazon Linux 2023/Fedora (dnf), and Ubuntu/Debian (apt) via `/etc/os-release`
- **Docker-based test suite** — integration tests for all supported platforms in `__tests__/`
- **Uninstaller cleanup guide** — `uninstall.sh` now prints the exact `rm -rf` command to fully remove all build artifacts

### Under the Hood

- Removed `mercurial` from yum dependencies (no longer needed)
- `mkdir -p` for idempotent re-runs
- Completion message runs `$HOME/bin/ffmpeg -version` to confirm success
- examples/package.json cleaned up (removed unused fields, fixed license to MIT)
- Regenerated package-lock.json with current lockfileVersion

## [1.0.2] - 2020-02-09

- **Node.js GIF example** — added sample code for converting sequential images to GIF using ffmpeg-stream

## [1.0.1] - 2020-01-30

- **GIF conversion examples** — added ffmpeg command examples for converting sequential images to GIF in README

## [1.0.0] - 2020-01-17

First release. Shell-based FFmpeg installer that builds FFmpeg and 9 encoder libraries (x264, x265, VP9, AV1, AAC, MP3, Opus, Vorbis, VPX) from source on CentOS/RHEL.

- **Full source build** — installs all dependencies via yum, then builds each encoder and FFmpeg from source as static libraries
- **cmake auto-upgrade** — detects cmake version and upgrades from source if below 3.5
- **Node.js examples** — sample script for converting sequential images to MP4 using ffmpeg-stream
- **FFmpeg command reference** — README includes common ffmpeg commands for video/image conversion

[1.0.0]: https://github.com/shumatsumonobu/ffmpeg-installer/releases/tag/v1.0.0
[1.0.1]: https://github.com/shumatsumonobu/ffmpeg-installer/compare/v1.0.0...v1.0.1
[1.0.2]: https://github.com/shumatsumonobu/ffmpeg-installer/compare/v1.0.1...v1.0.2
[2.0.0]: https://github.com/shumatsumonobu/ffmpeg-installer/compare/v1.0.2...v2.0.0
