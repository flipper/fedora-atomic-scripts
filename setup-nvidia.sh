#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root: sudo $0"; exit 1; }

if mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled"; then
  echo "Secure Boot is enabled. Reboot into your BIOS/UEFI settings and disable it, then run this again."
  exit 1
fi

step() { echo ">> $1"; shift; "$@" || { echo "FAILED: $*"; exit 1; }; }

write_repo() {
  cat > /etc/yum.repos.d/rpmfusion-nonfree-nvidia.repo <<'EOF'
[rpmfusion-nonfree-nvidia]
name=RPM Fusion for Fedora $releasever - Nonfree - Nvidia
#baseurl=http://download1.rpmfusion.org/nonfree/fedora/nvidia-driver/$releasever/$basearch/
metalink=https://mirrors.rpmfusion.org/metalink?repo=nonfree-fedora-nvidia-driver-$releasever&arch=$basearch
enabled=1
type=rpm-md
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://download1.rpmfusion.org/nonfree/fedora/RPM-GPG-KEY-rpmfusion-nonfree-fedora-2020
skip_if_unavailable=True
EOF
}

step "Writing RPM Fusion NVIDIA repo" write_repo

step "Installing NVIDIA packages" rpm-ostree install --idempotent \
  akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda

step "Setting kernel args" rpm-ostree kargs \
  --append-if-missing=rd.driver.blacklist=nouveau,nova_core \
  --append-if-missing=modprobe.blacklist=nouveau,nova_core \
  --append-if-missing=nvidia-drm.modeset=1

echo "All good. Reboot to apply: systemctl reboot"