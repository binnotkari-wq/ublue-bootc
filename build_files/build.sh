#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Suppression du remote flatpak fedora et de son service de re-création au boot
### Objectif : image sans aucun flatpak préconfiguré, validation du mécanisme de rebase
### https://github.com/ublue-os/main/blob/main/build_files/install.sh
dnf5 remove -y fedora-flathub-remote

# rm -f /etc/flatpak/remotes.d/*.flatpakrepo
# rm -f /usr/share/flatpak/remotes.d/*.flatpakrepo
# flatpak remote-delete --system fedora --force || true


### Suppression de logiciels RPM non désirés
# dépendances vérifiées sur un système installé :
# rpm -qa | grep -iE 'firefox|gnome-tour|gnome-software|^qt|qgnomeplatform'
# rpm -q --whatrequires gnome-software
# rpm -q --whatrequires qt5-qtwayland qt6-qtwayland
dnf5 remove -y \
  firefox \
  firefox-langpacks \
  gnome-tour \
  gnome-software \
  gnome-software-rpm-ostree \
  qt5-qtbase \
  qt6-qtbase


### Suppression des extensions GNOME Shell par défaut et de la session classique associée
### rpm -qa | grep -iE 'gnome-shell-extension*'
### ainsi que rpm -q --whatrequires pour chauqe paquet
dnf5 remove -y \
  gnome-classic-session \
  gnome-shell-extension-apps-menu \
  gnome-shell-extension-launch-new-instance \
  gnome-shell-extension-places-menu \
  gnome-shell-extension-window-list \
  gnome-shell-extension-background-logo





### Services système : désactivation classique
systemctl disable \
  NetworkManager-wait-online.service \
  ModemManager.service

### Services système : masquage (statique ou activation par socket/dbus)
systemctl mask \
  geoclue.service \
  gssproxy.service \
  sssd-kcm.service sssd-kcm.socket \
  pcscd.service pcscd.socket

### Services utilisateur (--global : pas de session active pendant le build)
systemctl --global mask \
  evolution-addressbook-factory.service \
  evolution-calendar-factory.service \
  evolution-alarm-notify.service \
  evolution-source-registry.service \
  org.gnome.SettingsDaemon.Smartcard.service \
  org.gnome.SettingsDaemon.Wwan.service



### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# dnf5 install -y tmux

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

# systemctl enable podman.socket



### Ajout de Flathub (statique, prêt à l'emploi si besoin plus tard)
### https://github.com/ublue-os/main/blob/main/build_files/install.sh
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo
