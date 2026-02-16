# Development Container - Base Image
# Minimal base with common utilities. Tools installed via devcontainer features.
FROM ubuntu:24.04

# ============================================================================
# Common utilities and JetBrains IDE dependencies
# ============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    procps \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libfreetype6 \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*
