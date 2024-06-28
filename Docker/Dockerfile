FROM golang:1.22.4@sha256:a66eda637829ce891e9cf61ff1ee0edf544e1f6c5b0e666c7310dce231a66f28 AS builder
WORKDIR /app
ARG VERSION=${VERSION:-v1.68.0}
# https://tailscale.com/kb/1118/custom-derp-servers/
RUN go install tailscale.com/cmd/derper@${VERSION}
RUN go install tailscale.com/cmd/derpprobe@${VERSION}

FROM ubuntu:noble@sha256:2e863c44b718727c860746568e1d54afd13b2fa71b160f5cd9058fc436217b30
WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=builder /go/bin/derper .
COPY --from=builder /go/bin/derpprobe .
COPY Docker/entrypoint.sh /app/entrypoint.sh
COPY Docker/healthprobe.sh /app/healthprobe.sh

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils ca-certificates curl jq && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /app/certs && \
    chmod +x /app/entrypoint.sh && \
    chmod +x /app/healthprobe.sh

ENTRYPOINT ["/app/entrypoint.sh"]
