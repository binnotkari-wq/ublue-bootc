# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Base Image
FROM quay.io/fedora-ostree-desktops/silverblue:44

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### build.sh doit avoir été éxécuté pour les RUN suivants.

### INTEGRATION HOMEBREW (ublue-os/brew)
# 1. Copie des fichiers système d'organisation Brew depuis l'image OCI officielle
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /

# 2. Activation des services systemd natifs d'ublue pour la gestion de Brew
# Dans un Containerfile (ou Dockerfile), la portée d'une option --mount est strictement
# limitée à la seule instruction RUN où elle est écrite. On spécifie donc à nouveau.
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /usr/bin/systemctl preset brew-setup.service && \
    /usr/bin/systemctl preset brew-update.timer && \
    /usr/bin/systemctl preset brew-upgrade.timer

### Application des permissions d'exécution sur les scripts et services perso
RUN chmod 755 /etc/scripts/system-update.sh && \
    chmod 755 /etc/scripts/bootc-welcome.sh
    
RUN chmod 644 /etc/profile.d/10-environment.sh && \
    chmod 755 /etc/skel/Script.sh

RUN dconf update

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
