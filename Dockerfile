FROM fedora:39

# Install the required package 
RUN <<INSTALL

dnf install -y qt-creator fzf which

INSTALL
