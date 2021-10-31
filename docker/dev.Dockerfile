FROM alpine:edge

RUN apk add nodejs npm alpine-sdk xvfb git gtk+3.0 \
    python3 py3-pip chromium dbus libx11-dev \
    python2 libsecret-dev libxkbfile-dev \
    bash coreutils dumb-init tailscale;
    npm i -g yarn

WORKDIR /usr/src

EXPOSE 3000

ENTRYPOINT [ "dumb-init" ]
CMD [ "bash" ]