#! /bin/env bash
set -ouex pipefail

# Global variables
DOWNLOAD_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
JQ_PARSE_RELEASE=".Releases | sort_by(.ReleaseDate) | last"
JQ_PARSE_PACKAGE=".File[] | select(.Identifier | contains(\".deb\")) | .Url"
JQ_PARSE_SHA512=".File[] | select(.Identifier | contains(\".deb\")) | .Sha512CheckSum"

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
