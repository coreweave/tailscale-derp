response=$(curl --head -L -w '%{http_code}' -o /dev/null -s -k https://"${DERP_HOSTNAME}"/derp/probe -m "${CURL_TIMEOUT:-2}")
if [ $? -ne 0 ]; then
  echo "Error: curl failed"
  exit 1
fi

if [[ "$response" -lt "200" ]] || [[ "$response" -ge "400" ]]; then
    echo "failed curl for ${PROBE_ADDRESS} with response $response" >&2
    exit 1
fi


if [[ $DERP_VERIFY_CLIENTS == "true" && $CONTAINERBOOT == "false" ]];
  then
    DERP_MAP="local"
    if ! /usr/local/bin/tailscale status --peers=false --json | grep -q 'Online.*true'
      then
        echo "Tailscale is not online and DERP_VERIFY_CLIENTS is true"
        exit 1
      fi; 
  else
    DERP_MAP="file:///app/derpmap.json"
fi

# This is a single-node DERP region, so there are no peers to mesh with.
# derpprobe still adds a 900->900 mesh probe by default (--mesh-interval=15s),
# which panics on a nil pointer when no mesh key is configured. Disable it with
# --mesh-interval=0 and rely on the TLS probe.
/usr/local/bin/derpprobe --derp-map $DERP_MAP --mesh-interval=0 --once

if [ $? -ne 0 ]; then
  echo "Error: derpprobe failed"
  exit 1
fi
