ARG RELEASE_TAG
FROM --platform=linux/amd64 registry.gitlab.com/gitpodify/openvscode-server-on-musl/nightly:$RELEASE_TAG as source

FROM scratch

COPY --from=source /home/gitpod/.gitpodified-server /openvscode
