# OpenVSCode Server on musl-based distros

Builds of OpenVSCode Server for musl-based distros like Alpine Linux, available on GHCR and GitLab Container Registry on GitLab SaaS.

## Build

### With Docker

TBD

### Manually with the source tree

You need an musl-based Linux distro, like Alpine Linux to proceed. Alternatively, you may opt to use Docker instead.

1. Install build dependencies with `apk add nodejs npm alpine-sdk xvfb git gtk+3.0 python3 py3-pip chromium dbus---`. Since the upstream uses Yarn, don't forget to `npm i -g yarn`.
2. Clone the OpenVSCode Server tree with `git clone https://github.com/gitpod-io/openvscode-server`. To checkout to an stable release, [check the releases page first](https://github.com/gitpod-io/openvscode-server/releases) and look for stable releases with tag names with `openvscode-server-` prefix. Checkout using `git switch openvscode-server-v$VERSION` where `$VERSION` is the semver version from the releases page.
3. RUn `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 ELECTRON_SKIP_BINARY_DOWNLOAD=1 yarn --frozen-lockfile --network-timeout 180000; yarn playwright-install` to install Node.js packages without Electron and Playright.
4. Finally run `yarn gulp server-min` to build and prepare for distribution. Optionally you can run the following to do both intergation and smoke tests on your own:

```
set -e; yarn --cwd test/smoke compile; yarn --cwd test/integration/browser compile; export VSCODE_REMOTE_SERVER_PATH="$PWDr/server-pkg"; \
./resources/server/test/test-web-integration.sh --browser chromium; yarn smoketest --web --headless --electronArgs="--disable-dev-shm-usage --use-gl=swiftshader"
```
5. YOur build is available on `./server-pkg`!
