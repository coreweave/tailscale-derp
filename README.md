# tailscale-derp

Helm chart and container image for running [tailscale DERP](https://tailscale.com/kb/1232/derp-servers) servers.

Tailscale offers [documentation for running custom DERP servers](https://tailscale.com/kb/1118/custom-derp-servers).

The helm chart is availble in [`./chart/tailscale-derp`](./chart/tailscale-derp) and it's supporting container image can be found in [`Docker`](./Docker).

The container image follows tailscale's upstream version.

## Getting Started

## TL;DR

```console
helm install tailscale-derp oci://ghcr.io/coreweave/tailscale-derp/chart/tailscale-derp
```

## Installing the Chart

To install the chart with the release name `tailscale-derp`

```console
helm install tailscale-derp oci://ghcr.io/coreweave/tailscale-derp/chart/tailscale-derp
```

## Uninstalling the Chart

To uninstall the `tailscale-derp` deployment

```console
helm uninstall tailscale-derp
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Read through the [values.yaml](./chart/tailscale-derp/values.yaml) file. It has several commented out suggested values.
`DERP_*` enviroment variables are arguments passed down to the `derper` [binary](https://tailscale.com/kb/1118/custom-derp-servers#step-1-starting-your-own-derp-server).

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

```console
helm install tailscale-derp \
  --set derpServerHostname="your-hostname.com" \
    oci://ghcr.io/coreweave/tailscale-derp/chart/tailscale-derp
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart.

```console
helm install tailscale-derp oci://ghcr.io/coreweave/tailscale-derp/chart/tailscale-derp -f values.yaml
```
