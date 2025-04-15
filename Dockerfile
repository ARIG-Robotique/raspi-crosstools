FROM fedora:40

# Install the required package 
RUN <<INSTALL

dnf install -y qt-creator fzf which rsync gcc-aarch-linux-gnu

INSTALL
