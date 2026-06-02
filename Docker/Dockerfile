FROM --platform=$BUILDPLATFORM golang:1.26 AS builder
WORKDIR /app
ARG VERSION=${VERSION:-v1.68.0}
ARG TARGETOS
ARG TARGETARCH
ENV CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH
# https://tailscale.com/kb/1118/custom-derp-servers/
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    go install \
      tailscale.com/cmd/derper@${VERSION} \
      tailscale.com/cmd/derpprobe@${VERSION} \
      tailscale.com/cmd/tailscaled@${VERSION} \
      tailscale.com/cmd/tailscale@${VERSION} \
      tailscale.com/cmd/containerboot@${VERSION} && \
    mkdir -p /out && \
    if [ -d "/go/bin/${GOOS}_${GOARCH}" ]; then \
      cp /go/bin/${GOOS}_${GOARCH}/* /out/; \
    else \
      cp /go/bin/* /out/; \
    fi

FROM ubuntu:noble
WORKDIR /usr/local/bin

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=builder /out/derper .
COPY --from=builder /out/derpprobe .
COPY --from=builder /out/tailscaled .
COPY --from=builder /out/tailscale .
COPY --from=builder /out/containerboot .
COPY Docker/entrypoint.sh /app/entrypoint.sh
COPY Docker/healthprobe.sh /app/healthprobe.sh

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl jq && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /app/certs && \
    chmod +x /app/entrypoint.sh && \
    chmod +x /app/healthprobe.sh

RUN chown -R 1000:1000 /app
USER 1000:1000

ENTRYPOINT ["/app/entrypoint.sh"]
