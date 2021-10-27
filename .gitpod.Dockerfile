FROM gitpod/workspace-full

# GLab CLI, Hadolint and Dive
RUN curl -s --compressed "https://madebythepinshub.gitlab.io/ppa/releases-key.gpg" | sudo apt-key add -; \
    echo "deb https://madebythepinshub.gitlab.io/ppa ./" | sudo tee /etc/apt/sources.list.d/thepinsteam-ppa-gitlab.list; \
    sudo install-packages glab dive

# GitHub CLI
RUN brew install gh