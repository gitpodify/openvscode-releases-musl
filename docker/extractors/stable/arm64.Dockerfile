ARG RELEASE_TAG
FROM --platform=linux/arm64 registry.gitlab.com/gitpodify/openvscode-server-on-musl/stable:$RELEASE_TAG as source

FROM scratch

COPY --from=source /home/gitpod/.gitpodified-server /openvscode
