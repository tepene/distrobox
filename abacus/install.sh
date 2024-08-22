#! /bin/env bash
set -ouex pipefail

# Global variables
DOWNLOAD_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
INIT_HOOK_SUCCESS_FILE="/opt/.init-hook-success"

#Check if distrobox init-hook has already run
if test -f "${INIT_HOOK_SUCCESS_FILE}"; then
  echo "distrobox init-hook has already successfully run"
  exit 0
fi

# Install dependencies
sudo apt-get update
sudo apt-get -y install --no-install-recommends libasound2-plugins libnss3

# Download and install abaclient
ABACLIENT_DOWNLOAD_BASE_URL="https://downloads.abacus.ch"
ABACLIENT_HREF_REGEX='href=["'\''\s]*\K[^"'\''\s]*\.run(?=["'\''])'
## Get all href's for linux installer
ABACLIENT_HREFS=($(curl -s "${ABACLIENT_DOWNLOAD_BASE_URL}/downloads/abaclient" | grep -oP "${ABACLIENT_HREF_REGEX}"))
## Sort results in numeric reverse order
readarray -td '' ABACLIENT_HREFS_SORTED < <(printf '%s\0' "${ABACLIENT_HREFS[@]}" | sort -rn)
## Download installer
ABACLIENT_DOWNLOAD_URL="${ABACLIENT_DOWNLOAD_BASE_URL}${ABACLIENT_HREFS_SORTED[0]}"
ABALCIENT_INSTALLER_NAME=$(basename "${ABACLIENT_DOWNLOAD_URL}")
wget -O "${DOWNLOAD_DIR}/${ABALCIENT_INSTALLER_NAME}" "${ABACLIENT_DOWNLOAD_URL}"
chmod +x "${DOWNLOAD_DIR}/${ABALCIENT_INSTALLER_NAME}"
"${DOWNLOAD_DIR}/${ABALCIENT_INSTALLER_NAME}"

# Set installed flag
touch "${INIT_HOOK_SUCCESS_FILE}"
