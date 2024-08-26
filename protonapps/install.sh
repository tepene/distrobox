#! /bin/env bash
set -ouex pipefail

# Global variables
DOWNLOAD_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
JQ_PARSE_RELEASE=".Releases | sort_by(.ReleaseDate) | last"
JQ_PARSE_PACKAGE=".File[] | select(.Identifier | contains(\".deb\")) | .Url"
JQ_PARSE_SHA512=".File[] | select(.Identifier | contains(\".deb\")) | .Sha512CheckSum"
INIT_HOOK_SUCCESS_FILE="/opt/.init-hook-success"

#Check if distrobox init-hook has already run
if test -f "${INIT_HOOK_SUCCESS_FILE}"; then
  echo "distrobox init-hook has already successfully run"
  exit 0
fi

# Install dependencies
sudo apt-get update
sudo apt-get -y install --no-install-recommends jq libasound2-plugins

## Install proton mail
PROTON_MAIL_VERSION_FILE="https://proton.me/download/mail/linux/version.json"
PROTON_MAIL_RELEASE_LATEST=$(curl -s "${PROTON_MAIL_VERSION_FILE}" | jq -r "${JQ_PARSE_RELEASE}")
PROTON_MAIL_PACKAGE_URL=$(echo "${PROTON_MAIL_RELEASE_LATEST}" | jq -r "${JQ_PARSE_PACKAGE}")
PROTON_MAIL_PACKAGE_NAME=$(basename "${PROTON_MAIL_PACKAGE_URL}")
PROTON_MAIL_PACKAGE_SHA512=$(echo "${PROTON_MAIL_RELEASE_LATEST}" | jq -r "${JQ_PARSE_SHA512}")
wget -O "${DOWNLOAD_DIR}/${PROTON_MAIL_PACKAGE_NAME}" "${PROTON_MAIL_PACKAGE_URL}"
if echo "${PROTON_MAIL_PACKAGE_SHA512} ${DOWNLOAD_DIR}/${PROTON_MAIL_PACKAGE_NAME}" | sha512sum --check; then
  echo "SHA512 checksum verification successful."
  sudo apt-get -y install --no-install-recommends "${DOWNLOAD_DIR}/${PROTON_MAIL_PACKAGE_NAME}"
else
  echo "SHA512 checksum verification failed. Aborting installation."
  exit 1
fi

## Install proton pass
PROTON_PASS_VERSION_FILE="https://proton.me/download/PassDesktop/linux/x64/version.json"
PROTON_PASS_RELEASE_LATEST=$(curl -s "${PROTON_PASS_VERSION_FILE}" | jq -r "${JQ_PARSE_RELEASE}")
PROTON_PASS_PACKAGE_URL=$(echo "${PROTON_PASS_RELEASE_LATEST}" | jq -r "${JQ_PARSE_PACKAGE}")
PROTON_PASS_PACKAGE_NAME=$(basename "${PROTON_PASS_PACKAGE_URL}")
PROTON_PASS_PACKAGE_SHA512=$(echo "${PROTON_PASS_RELEASE_LATEST}" | jq -r "${JQ_PARSE_SHA512}")
wget -O "${DOWNLOAD_DIR}/${PROTON_PASS_PACKAGE_NAME}" "${PROTON_PASS_PACKAGE_URL}"
if echo "${PROTON_PASS_PACKAGE_SHA512} ${DOWNLOAD_DIR}/${PROTON_PASS_PACKAGE_NAME}" | sha512sum --check; then
  echo "SHA512 checksum verification successful."
  sudo apt-get -y install --no-install-recommends "${DOWNLOAD_DIR}/${PROTON_PASS_PACKAGE_NAME}"
else
  echo "SHA512 checksum verification failed. Aborting installation."
  exit 1
fi

## Install proton vpn
PROTONVPN_DOWNLOAD_BASE_URL="https://repo.protonvpn.com/debian/dists/stable/main/binary-all"
PROTONVPN_HREF_REGEX='href=["'\'']\K[^"'\'']*protonvpn-stable-release.*?all\.deb(?=["'\''])'
## Get all href's for debian installer
PROTONVPN_HREFS=($(curl -sk -L "${PROTONVPN_DOWNLOAD_BASE_URL}" | grep -oP "${PROTONVPN_HREF_REGEX}"))
echo $PROTONVPN_HREFS
## Sort results in numeric reverse order
readarray -td '' PROTONVPN_HREFS_SORTED < <(printf '%s\0' "${PROTONVPN_HREFS[@]}" | sort -r)
## Download installer
PROTONVPN_DOWNLOAD_URL="${PROTONVPN_DOWNLOAD_BASE_URL}/${PROTONVPN_HREFS_SORTED[0]}"
PROTONVPN_INSTALLER_NAME=$(basename "${PROTONVPN_DOWNLOAD_URL}")
wget -O "${DOWNLOAD_DIR}/${PROTONVPN_INSTALLER_NAME}" "${PROTONVPN_DOWNLOAD_URL}"
## Install
sudo dpkg -i "${DOWNLOAD_DIR}/${PROTONVPN_INSTALLER_NAME}" && sudo apt-get update
sudo apt-get -y install --no-install-recommends proton-vpn-gnome-desktop

# Set installed flag
touch "${INIT_HOOK_SUCCESS_FILE}"
