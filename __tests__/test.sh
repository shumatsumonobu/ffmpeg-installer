#!/bin/sh
set -e

# ==============================================================================
# FFmpeg Installer Test Suite
#
# Builds and tests install.sh on all supported platforms using Docker.
# Each platform runs in an isolated container.
#
# Usage:
#   chmod +x __tests__/test.sh
#   ./__tests__/test.sh            # Test all platforms
#   ./__tests__/test.sh rocky      # Test single platform
#   ./__tests__/test.sh ubuntu     # Test single platform
#   ./__tests__/test.sh amzn       # Test single platform
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PASSED=0
FAILED=0
RESULTS=""

run_test() {
  name="$1"
  image="$2"

  echo ""
  echo "========================================"
  echo " Testing: $name ($image)"
  echo "========================================"

  if docker build \
    --build-arg BASE_IMAGE="$image" \
    -f "$SCRIPT_DIR/Dockerfile" \
    "$PROJECT_DIR" 2>&1; then
    echo ""
    echo "PASS: $name"
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\n  PASS  $name"
  else
    echo ""
    echo "FAIL: $name"
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\n  FAIL  $name"
  fi
}

# Determine which platforms to test
TARGET="${1:-all}"

case "$TARGET" in
  rocky)
    run_test "Rocky Linux 9" "rockylinux:9"
    ;;
  amzn)
    run_test "Amazon Linux 2023" "amazonlinux:2023"
    ;;
  ubuntu)
    run_test "Ubuntu 22.04" "ubuntu:22.04"
    ;;
  all)
    run_test "Rocky Linux 9" "rockylinux:9"
    run_test "Amazon Linux 2023" "amazonlinux:2023"
    run_test "Ubuntu 22.04" "ubuntu:22.04"
    ;;
  *)
    echo "Usage: $0 [rocky|amzn|ubuntu|all]"
    exit 1
    ;;
esac

echo ""
echo "========================================"
echo " Results: $PASSED passed, $FAILED failed"
echo "----------------------------------------"
printf "$RESULTS\n"
echo "========================================"

[ "$FAILED" -eq 0 ]
