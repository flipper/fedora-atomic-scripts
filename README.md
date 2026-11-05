# Fedora Atomic Scripts

Small, beginner-friendly setup scripts for **Fedora Atomic / immutable desktops** (Silverblue, Kinoite, Sericea, Onyx, etc.).

Each script does one job, prints what it is doing (`>> step name`), and stops with a clear message if something fails. They are safe to run more than once.

> **New to immutable Fedora?** The base system is read-only and updated as a whole image. Apps normally come from **Flatpak**, and system changes are made with `rpm-ostree`. Most changes only take effect **after a reboot**.

---

## Quick start

Open a terminal and paste the command for the script you want.

| Script | Run it like this |
|---|---|
| `setup-flatpak.sh` | `curl -fsSL https://raw.githubusercontent.com/flipper/fedora-atomic-scripts/main/setup-flatpak.sh \| bash` |
| `replace-firefox.sh` | `curl -fsSL https://raw.githubusercontent.com/flipper/fedora-atomic-scripts/main/replace-firefox.sh \| bash` |
| `setup-rpmfusion.sh` | `curl -fsSL https://raw.githubusercontent.com/flipper/fedora-atomic-scripts/main/setup-rpmfusion.sh \| sudo bash` |
| `setup-nvidia.sh` | `curl -fsSL https://raw.githubusercontent.com/flipper/fedora-atomic-scripts/main/setup-nvidia.sh \| sudo bash` |

**What does that command mean?**
- `curl -fsSL <url>` downloads the script quietly (and fails on errors instead of saving an error page).
- `| bash` hands the downloaded script to `bash` to run it.
- `| sudo bash` does the same but as administrator (root). You'll be asked for your password.

---

## What each script does

### `setup-flatpak.sh`: set up Flathub for your user
Run as: **normal user** (do *not* use sudo)

- Disables the system-wide `flathub`, `fedora` and `fedora-testing` Flatpak remotes (software sources).
- Adds the official **Flathub** store for **your user only** and enables it.
- Shows the final list of remotes.

Why: user-scope Flatpaks don't need admin rights, and this avoids mixing Fedora's Flatpak repos with Flathub.

### `replace-firefox.sh`: swap Firefox for LibreWolf
Run as: **normal user** (it asks for sudo itself when needed)

- Removes the built-in Firefox (and language packs) from the base image using `rpm-ostree override remove`. Skips this if it is already removed.
- Installs **LibreWolf**, a privacy-focused Firefox fork, from Flathub as a user Flatpak.
- Needs Flathub, so run `setup-flatpak.sh` first.
- **Reboot afterwards** so the Firefox removal takes effect.

### `setup-rpmfusion.sh`: add RPM Fusion repositories
Run as: **root** (`sudo`)

- Writes the **RPM Fusion Free** and **Nonfree** repository files to `/etc/yum.repos.d/`.
- RPM Fusion provides extras Fedora doesn't ship itself (codecs, drivers, etc.).
- Only adds the repositories. It does not install anything.
- Optional, and not required for the NVIDIA driver (`setup-nvidia.sh` brings its own repo).

### `setup-nvidia.sh`: install proprietary NVIDIA drivers
Run as: **root** (`sudo`)

- Checks **Secure Boot**. If it is on, the script stops and tells you to turn it off in your BIOS/UEFI first (the driver modules aren't signed).
- Adds the RPM Fusion NVIDIA driver repository. This repo already contains everything the driver needs (including `akmod-nvidia`), so you do **not** need to run `setup-rpmfusion.sh` first.
- Layers these packages with `rpm-ostree`: `akmod-nvidia`, `xorg-x11-drv-nvidia`, `xorg-x11-drv-nvidia-cuda`.
- Sets kernel arguments to block the open-source `nouveau` / `nova_core` drivers and enable `nvidia-drm.modeset=1` (needed for Wayland).
- **Reboot afterwards.** The driver gets built on first boot, so give it a few minutes before checking with `nvidia-smi`.
- Only use this if you have an NVIDIA graphics card.

---

## Suggested order

1. `setup-flatpak.sh`
2. `replace-firefox.sh` (optional)
3. `setup-rpmfusion.sh` (optional, only if you want other RPM Fusion packages)
4. `setup-nvidia.sh` (NVIDIA GPUs only, works on its own)
5. Reboot: `systemctl reboot`

## Troubleshooting

- **"Run as root"**: use `| sudo bash` instead of `| bash`.
- **"Don't run as root"**: remove `sudo`; Flatpak must run in your user account.
- **"Secure Boot is enabled"**: disable it in your BIOS/UEFI, then rerun `setup-nvidia.sh`.
- **A step says `FAILED`**: check your internet connection and rerun. Finished steps are skipped or harmless to repeat.
- **Undo an rpm-ostree change**: `rpm-ostree rollback` (then reboot) returns to the previous deployment.
  Reset a Firefox removal with `rpm-ostree override reset firefox firefox-langpacks`.
