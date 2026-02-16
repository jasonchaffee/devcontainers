#!/bin/bash
set -e

VERSION="${VERSION:-latest}"
INSTALL_COMPONENTS="${INSTALLCOMPONENTS:-}"

echo "Installing Google Cloud CLI..."

# Detect architecture
ARCH=$(uname -m)
case "${ARCH}" in
    x86_64) GCLOUD_ARCH="x86_64" ;;
    aarch64|arm64) GCLOUD_ARCH="arm" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Install dependencies
if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y --no-install-recommends curl python3 gnupg
    rm -rf /var/lib/apt/lists/*
fi

# Download and install gcloud
cd /tmp
if [ "${VERSION}" = "latest" ]; then
    curl -fsSL "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz" -o gcloud.tar.gz
else
    curl -fsSL "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${VERSION}-linux-${GCLOUD_ARCH}.tar.gz" -o gcloud.tar.gz
fi

tar -xzf gcloud.tar.gz -C /opt
rm gcloud.tar.gz

# Install gcloud
/opt/google-cloud-sdk/install.sh --quiet --path-update=true

# Add to PATH
ln -sf /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
ln -sf /opt/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil
ln -sf /opt/google-cloud-sdk/bin/bq /usr/local/bin/bq

# Install additional components if specified
if [ -n "${INSTALL_COMPONENTS}" ]; then
    echo "Installing additional components: ${INSTALL_COMPONENTS}"
    IFS=',' read -ra COMPONENTS <<< "${INSTALL_COMPONENTS}"
    for component in "${COMPONENTS[@]}"; do
        /opt/google-cloud-sdk/bin/gcloud components install "${component}" --quiet
    done
fi

echo "Google Cloud CLI installed successfully!"
gcloud --version
