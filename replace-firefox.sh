#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Don't run as root, flatpak needs your user scope. Run: $0"; exit 1; }

step() { echo ">> $1"; shift; "$@" || { echo "FAILED: $*"; exit 1; }; }

remove_firefox() {
  if rpm-ostree status | grep -q "RemovedBasePackages:.*firefox"; then
    echo "   firefox already removed, skipping"
  else
    sudo rpm-ostree override remove firefox firefox-langpacks
  fi
}

step "Removing firefox from base image" remove_firefox

step "Installing LibreWolf (user)" flatpak install --user -y flathub io.gitlab.librewolf-community

echo "All good. Reboot to apply the firefox removal: systemctl reboot"