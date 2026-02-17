#!/bin/bash
set -e

VERSION="${VERSION:-latest}"
INSTALL_COMPONENTS="${INSTALLCOMPONENTS:-}"

# Components list
COMPONENTS=""
[ "${INSTALLCRC32C}" = "true" ] && COMPONENTS="${COMPONENTS},gcloud-crc32c"
[ "${INSTALLGKEGCLOUDAUTHPLUGIN}" = "true" ] && COMPONENTS="${COMPONENTS},gke-gcloud-auth-plugin"
[ "${INSTALLSKAFFOLD}" = "true" ] && COMPONENTS="${COMPONENTS},skaffold"
[ "${INSTALLKUBECTL}" = "true" ] && COMPONENTS="${COMPONENTS},kubectl"
[ "${INSTALLBETA}" = "true" ] && COMPONENTS="${COMPONENTS},beta"
[ "${INSTALLALPHA}" = "true" ] && COMPONENTS="${COMPONENTS},alpha"
[ "${INSTALLAPPENGINEJAVA}" = "true" ] && COMPONENTS="${COMPONENTS},app-engine-java"
[ "${INSTALLTERRAFORMTOOLS}" = "true" ] && COMPONENTS="${COMPONENTS},terraform-tools"

# Grouped emulators
if [ "${INSTALLEMULATORS}" = "true" ]; then
    COMPONENTS="${COMPONENTS},pubsub-emulator,cloud-spanner-emulator,bigtable"
fi

# Add any additional components provided as a string
if [ -n "${INSTALL_COMPONENTS}" ]; then
    COMPONENTS="${COMPONENTS},${INSTALL_COMPONENTS}"
fi

# Clean up component list (remove leading comma if present)
COMPONENTS=$(echo "${COMPONENTS}" | sed 's/^,//')

echo "Installing Google Cloud CLI (version: ${VERSION})..."

# Detect architecture
ARCH=$(uname -m)
case "${ARCH}" in
    x86_64) GCLOUD_ARCH="x86_64" ;;
    aarch64|arm64) GCLOUD_ARCH="arm" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Install dependencies
if command -v apt-get &> /dev/null; then
    echo "Updating apt-get..."
    apt-get update || (sleep 5 && apt-get update) || (sleep 10 && apt-get update)
    apt-get install -y --no-install-recommends curl python3 gnupg
    rm -rf /var/lib/apt/lists/*
elif command -v apk &> /dev/null; then
    apk add --no-cache curl python3 gnupg bash
elif command -v dnf &> /dev/null; then
    dnf install -y --allowerasing curl python3 gnupg
elif command -v yum &> /dev/null; then
    yum install -y --allowerasing curl python3 gnupg
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
if [ -n "${COMPONENTS}" ]; then
    echo "Installing components: ${COMPONENTS}"
    IFS=',' read -ra COMP_LIST <<< "${COMPONENTS}"
    for component in "${COMP_LIST[@]}"; do
        echo "Installing component: ${component}..."
        /opt/google-cloud-sdk/bin/gcloud components install "${component}" --quiet || \
        (sleep 5 && /opt/google-cloud-sdk/bin/gcloud components install "${component}" --quiet) || \
        (sleep 10 && /opt/google-cloud-sdk/bin/gcloud components install "${component}" --quiet)
    done
fi

echo "Google Cloud CLI installed successfully!"
gcloud --version
