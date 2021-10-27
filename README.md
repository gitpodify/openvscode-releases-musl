# OpenVSCode Server on musl-based distros

This repository handles the CI side on builds of OpenVSCode Server for musl-based distros like Alpine Linux, available on GHCR and GitLab Container Registry on GitLab SaaS.

## Available Images

| Quality | GHCR | GLCR on GitLab SaaS |
| --- | --- | --- |
| Nightly / Insiders | `ghcr.io/gitpodify/openvscode-releases-musl/nightly` | `registry.gitlab.com/gitpodify/openvscode-releases-musl/nightly` |
| Stable | `ghcr.io/gitpodify/openvscode-releases-musl/stable` | `registry.gitlab.com/gitpodify/openvscode-releases-musl/stable`

## Build Instructions

### With Docker/Podman

To build against your machine's CPU arch:

```bash
# Assumes community/github-cli package, among jq and sed is installed on Alpine Linux v3.14+
NIGHTLY_RELEASE_TAG="$(gh api repos/gitpod-io/openvscode-server/releases | jq -r 'map(select(.prerelease)) | first | .tag_name' | sed -E 's/openvscode-server-//gm;t;d')"
# Needed for our image tags to be compliant with SemVer spec :)
IMAGE_TAG="$(echo $NIGHTLY_RELEASE_TAG | sed  -E 's/openvscode-server-nightly-v//gm;t;d')"

# replace docker with podman if needed
docker build -t your-gitlab-container-registry-here.tld/gitpodify/openvscode-releases-musl/nightly:$IMAGE_TAG \
    --build-arg=RELEASE_TAG=$NIGHTLY_RELEASE_TAG .
```

To build against both amd64 and arm64[^1]:

```bash
# TODO
```

[^1]: Multi-arch builds on Podman is currently painful, as per <https://lists.podman.io/archives/list/podman%40lists.podman.io/message/EIYJSUW4FM4QXSESJK4GAUA74GOHLCUF/>.

### Manually with the source tree

You need an musl-based Linux distro, like Alpine Linux to proceed. Alternatively, you may opt to use Docker instead.

1. Install build dependencies with `apk add nodejs npm alpine-sdk xvfb git gtk+3.0 python3 py3-pip chromium dbus libx11-dev python2 libsecret-dev libxkbfile-dev bash coreutils`. Since the upstream uses Yarn, don't forget to `npm i -g yarn`.
2. Clone the OpenVSCode Server tree with `git clone https://github.com/gitpod-io/openvscode-server`. To checkout to an stable release, [check the releases page first](https://github.com/gitpod-io/openvscode-server/releases) and look for stable releases with tag names with `openvscode-server-` prefix. Checkout using `git switch openvscode-server-v$VERSION` where `$VERSION` is the semver version from the releases page.
3. RUn `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 ELECTRON_SKIP_BINARY_DOWNLOAD=1 yarn --frozen-lockfile --network-timeout 180000; yarn playwright-install` to install Node.js packages without Electron and Playright.
4. Finally run `yarn gulp server-min` to build and prepare for distribution. Optionally you can run the following to do both intergation and smoke tests on your own:

```bash
set -e; yarn --cwd test/smoke compile; yarn --cwd test/integration/browser compile; export VSCODE_REMOTE_SERVER_PATH="$PWDr/server-pkg"; \
./resources/server/test/test-web-integration.sh --browser chromium; yarn smoketest --web --headless --electronArgs="--disable-dev-shm-usage --use-gl=swiftshader"
```

5. Your build is available on `./server-pkg`! You can move this around and run `./server.sh` to run OpenVSCode server.
