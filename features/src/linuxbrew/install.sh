#!/bin/bash
set -e

INSTALLPACKAGES="${INSTALLPACKAGES:-}"
BREW_PREFIX="/home/linuxbrew/.linuxbrew"
BREW_BIN="${BREW_PREFIX}/bin/brew"

echo "Installing Linuxbrew..."

if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
    TARGET_USER="${_REMOTE_USER}"
else
    TARGET_USER="vscode"
fi

install_dependencies() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update || (sleep 5 && apt-get update) || (sleep 10 && apt-get update)
        apt-get install -y --no-install-recommends build-essential procps curl file git ca-certificates
        rm -rf /var/lib/apt/lists/*
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache build-base procps curl file git ca-certificates bash
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y --allowerasing gcc gcc-c++ make procps-ng curl file git ca-certificates
    elif command -v yum >/dev/null 2>&1; then
        yum install -y --allowerasing gcc gcc-c++ make procps-ng curl file git ca-certificates
    else
        echo "ERROR: unsupported package manager for Linuxbrew dependencies" >&2
        exit 1
    fi
}

install_dependencies

if ! id linuxbrew >/dev/null 2>&1; then
    useradd -m -s /bin/bash linuxbrew
fi

if ! getent group linuxbrew >/dev/null 2>&1; then
    groupadd linuxbrew
fi

mkdir -p /home/linuxbrew
chown linuxbrew:linuxbrew /home/linuxbrew

if [ ! -x "${BREW_BIN}" ]; then
    installer="/tmp/install-homebrew.sh"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "${installer}"
    chmod +x "${installer}"
    su - linuxbrew -c "NONINTERACTIVE=1 CI=1 /bin/bash ${installer}"
    rm -f "${installer}"
else
    echo "Linuxbrew already installed at ${BREW_PREFIX}"
fi

if id "${TARGET_USER}" >/dev/null 2>&1; then
    usermod -aG linuxbrew "${TARGET_USER}" 2>/dev/null || true
fi

chgrp -R linuxbrew /home/linuxbrew 2>/dev/null || true
chmod -R g+rwX /home/linuxbrew 2>/dev/null || true
find /home/linuxbrew -type d -exec chmod g+s {} + 2>/dev/null || true

mkdir -p /etc/profile.d /usr/local/bin
cat >/etc/profile.d/linuxbrew.sh <<EOF
export HOMEBREW_PREFIX="${BREW_PREFIX}"
export HOMEBREW_CELLAR="${BREW_PREFIX}/Cellar"
export HOMEBREW_REPOSITORY="${BREW_PREFIX}/Homebrew"
export PATH="${BREW_PREFIX}/bin:${BREW_PREFIX}/sbin:\$PATH"
export MANPATH="${BREW_PREFIX}/share/man:\${MANPATH:-}"
export INFOPATH="${BREW_PREFIX}/share/info:\${INFOPATH:-}"
EOF

ln -sf "${BREW_BIN}" /usr/local/bin/brew

if [ -n "${INSTALLPACKAGES}" ]; then
    # shellcheck disable=SC2086
    su - linuxbrew -c "eval \"\$(${BREW_BIN} shellenv)\" && ${BREW_BIN} install ${INSTALLPACKAGES}"
fi

"${BREW_BIN}" --version
echo "Linuxbrew installed successfully!"
