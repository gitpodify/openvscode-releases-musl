FROM alpine:3.14 as bulldozer

# Install package dependencies and Yarn
RUN apk add nodejs npm alpine-sdk xvfb git gtk+3.0 \
    python3 py3-pip chromium dbus libx11-dev \
    python2 libsecret-dev libxkbfile-dev \
    bash coreutils; \
    npm i -g yarn

#COPY scripts/build-code.sh /usr/local/bin/build-code
WORKDIR /usr/src

# Clone repo and checkout to stable release tag
ARG RELEASE_TAG
#ARG MAX_MEMORY_SIZE=4095
RUN git clone https://github.com/gitpod-io/openvscode-server openvscode-server; \
    git -C "./openvscode-server" checkout openvscode-server-$RELEASE_TAG

WORKDIR /usr/src/openvscode-server

# Install deps
RUN PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 ELECTRON_SKIP_BINARY_DOWNLOAD=1 yarn --frozen-lockfile --network-timeout 180000; yarn playwright-install

# Prep for distrib
RUN yarn gulp server-min; ls -Al

# Run integration tests
#RUN set -e; yarn --cwd test/smoke compile; yarn --cwd test/integration/browser compile; \
#    export VSCODE_REMOTE_SERVER_PATH="/usr/src/openvscode-server/server-pkg"; \
#    ./resources/server/test/test-web-integration.sh --browser chromium; \
#    yarn smoketest --web --headless --electronArgs="--disable-dev-shm-usage --use-gl=swiftshader"

FROM alpine:3.14 as release

ARG USERNAME=gitpod
ARG USER_UID=1000
#ARG USER_GID=$USER_UID

# Install some dependencies
RUN apk add --no-cache wget curl git sudo dumb-init bash coreutils

# Creating the user and usergroup
RUN adduser -D -u $USER_UID $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

COPY --from=bulldozer /usr/src/openvscode-server/server-pkg /home/gitpod/.gitpodified-server

RUN chown -R $USERNAME:$USERNAME /home/gitpod/.gitpodified-server; \
    mkdir -p /workspace; \
    chown -R $USERNAME:$USERNAME /workspace;

USER $USERNAME
WORKDIR /workspace

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV HOME=/workspace
ENV EDITOR=code
ENV VISUAL=code
ENV GIT_EDITOR="code --wait"
ENV OPENVSCODE_SERVER_ROOT=/home/gitpod/.gitpodified-server

EXPOSE 3000

ENTRYPOINT ${OPENVSCODE_SERVER_ROOT}/server.sh
