# Start from the official Fedora 44 Kinoite OCI image
FROM quay.io/fedora/fedora-kinoite:44

# Add repos here before install
# RUN tee ...repo contents here to go into repo file....

# Add your custom package overlays, rpmfusion can also go here
# Since we're using bootc, we use standard dnf commands, you can just install and also swap toolbox for distrobox, etc.
# Use -y for all dnf commands as it can't be interactive
RUN dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
RUN dnf -y install intel-media-driver
RUN dnf -y swap ffmpeg-free ffmpeg --allowerasing
RUN dnf -y install @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
RUN dnf -y install mesa-va-drivers-freeworld
RUN dnf -y swap mesa-vulkan-drivers{,-freeworld}
# I recommend following my template in Container-custom-example -- one RUN block for removals with a dnf clean all
# one RUN block for hardware drivers and codecs (RPMFusion etc.) with a dnf clean all, and one RUN block for your GUI apps/extra CLI tools
RUN dnf -y install \
    libvirt \
    virt-manager \ 
    distrobox \
    neovim \
    bcc \
    bpftrace \
    nicstat \
    numactl \
    sysprof \
    sysstat \
    tiptop \
    zsh \
    fish \
    chromium \
    emacs && \
    dnf clean all -y
RUN dnf -y config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
RUN dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
RUN dnf -y install tailscale
RUN systemctl enable docker
# Custom services enable/disable or none at all can go here as Fedora default-enables most. Stringing together with && is a good idea.
# RUN systemctl enable non-default.service

# Here you can run any image-layer-level /etc overrides. Useful if you don't want to have to think about these or have a specific need.
# In general, not usually necessary for most people, but YMMV. You can always do these configs manually.
# RUN echo "some-content" > /etc/some-default-os-config
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
RUN dnf -y update
RUn dnf -y install code

# Important: Label the image as bootc-compatible
LABEL containers.bootc=1
