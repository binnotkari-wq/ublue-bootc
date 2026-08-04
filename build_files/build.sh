#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Exécution des modules (conserver cet ordre)
#/ctx/trimming.sh
#/ctx/tweaks.sh
#/ctx/softwares.sh

### Nettoyage final
dnf5 autoremove -y
dnf5 clean all
### NB : /var/cache, /var/log et /tmp sont des montages provisoire pendant le build, ils sont donc hors de l'image qui reste donc sans résidus
