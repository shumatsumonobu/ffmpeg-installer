# Tests

Docker-based integration tests for `install.sh` across all supported platforms.

## Prerequisites

- Docker

## Usage

```sh
chmod +x __tests__/test.sh

# Test all platforms
./__tests__/test.sh

# Test single platform
./__tests__/test.sh centos    # CentOS 7
./__tests__/test.sh amzn      # Amazon Linux 2023
./__tests__/test.sh ubuntu    # Ubuntu 22.04
```

## What it does

1. Starts a Docker container for each target OS
2. Runs `bin/install.sh` inside the container
3. Verifies `ffmpeg -version` exits successfully
4. Reports PASS / FAIL per platform

## Notes

- Full build takes **30 min ~ 1 hour per platform** (all libraries are compiled from source)
- No files are written to the host — everything runs inside disposable containers
- Test a single platform first to save time, then run the full suite when ready
