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

/usr/local/bin/derpprobe --derp-map $DERP_MAP --once

if [ $? -ne 0 ]; then
  echo "Error: derpprobe failed"
  exit 1
fi
