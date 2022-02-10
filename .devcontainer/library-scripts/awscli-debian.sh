#!/usr/bin/env bash

# Syntax: ./awscli-debian.sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Function to run apt-get if needed
apt_get_update_if_needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

install_using_pip() {
    echo "(*) No pre-built binaries available in apt-cache. Installing via pip3."
    if ! dpkg -s python3-minimal python3-pip libffi-dev python3-venv > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install python3-minimal python3-pip libffi-dev python3-venv
    fi
    export PIPX_HOME=/usr/local/pipx
    mkdir -p ${PIPX_HOME}
    export PIPX_BIN_DIR=/usr/local/bin
    export PYTHONUSERBASE=/tmp/pip-tmp
    export PIP_CACHE_DIR=/tmp/pip-tmp/cache
    pipx_bin=pipx
    if ! type pipx > /dev/null 2>&1; then
        pip3 install --disable-pip-version-check --no-cache-dir --user pipx
        pipx_bin=/tmp/pip-tmp/bin/pipx
    fi

    set +e
        ${pipx_bin} install --pip-args '--no-cache-dir --force-reinstall' -f awscli

        # Fail gracefully
        if [ "$?" != 0 ]; then
            echo "Could not install awscli via pip"
            rm -rf /tmp/pip-tmp
            return 1
        fi
    set -e
}

# See if we're on x86_64 and if so, install via apt-get, otherwise use pip3
echo "(*) Installing AWS CLI..."
use_pip="true"

if [ "${use_pip}" = "true" ]; then
    install_using_pip

    if [ "$?" != 0 ]; then
        echo "Please provide a valid version for your distribution."
        exit 1
    fi
fi

echo "Done!"