#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Don't run as root, flathub needs your user scope. Run: $0"; exit 1; }

step() { echo ">> $1"; shift; "$@" || { echo "FAILED: $*"; exit 1; }; }

disable_remote() {
  if flatpak remotes --system --columns=name | grep -qx "$1"; then
    sudo flatpak remote-modify --system --disable "$1"
  else
    echo "   already disabled or missing, skipping"
  fi
}

for remote in flathub fedora fedora-testing; do
  step "Disabling system remote: $remote" disable_remote "$remote"
done

step "Adding flathub on user scope" flatpak remote-add --user --if-not-exists \
  flathub https://dl.flathub.org/repo/flathub.flatpakrepo

step "Enabling user flathub" flatpak remote-modify --user --enable flathub

step "Current remotes" flatpak remotes --show-disabled

echo "All good."