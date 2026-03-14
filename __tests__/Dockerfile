ARG BASE_IMAGE=amazonlinux:2023
FROM ${BASE_IMAGE}

# Docker containers run as root — provide a sudo shim so install.sh works unmodified
# Ubuntu/Debian images ship with empty package lists — run apt-get update first
RUN if ! command -v sudo > /dev/null 2>&1; then \
      printf '#!/bin/sh\nexec "$@"\n' > /usr/local/bin/sudo && \
      chmod +x /usr/local/bin/sudo; \
    fi && \
    if command -v apt-get > /dev/null 2>&1; then \
      apt-get update; \
    fi

# Copy installer scripts
COPY bin/ /work/bin/

# Run install
RUN chmod +x /work/bin/install.sh && /work/bin/install.sh

# Verify ffmpeg works
RUN $HOME/bin/ffmpeg -version
