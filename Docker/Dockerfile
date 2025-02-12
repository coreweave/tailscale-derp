FROM golang:1.24 AS builder
WORKDIR /app
ARG VERSION=${VERSION:-v1.68.0}
# https://tailscale.com/kb/1118/custom-derp-servers/
RUN go install tailscale.com/cmd/derper@${VERSION}
RUN go install tailscale.com/cmd/derpprobe@${VERSION}
RUN go install tailscale.com/cmd/tailscaled@${VERSION}
RUN go install tailscale.com/cmd/tailscale@${VERSION}
RUN go install tailscale.com/cmd/containerboot@${VERSION}

FROM ubuntu:noble
WORKDIR /usr/local/bin

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=builder /go/bin/derper .
COPY --from=builder /go/bin/derpprobe .
COPY --from=builder /go/bin/tailscaled .
COPY --from=builder /go/bin/tailscale .
COPY --from=builder /go/bin/containerboot .
COPY Docker/entrypoint.sh /app/entrypoint.sh
COPY Docker/healthprobe.sh /app/healthprobe.sh

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils ca-certificates curl jq && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /app/certs && \
    chmod +x /app/entrypoint.sh && \
    chmod +x /app/healthprobe.sh

ENTRYPOINT ["/app/entrypoint.sh"]
