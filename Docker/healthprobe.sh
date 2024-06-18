response=$(curl --head -L -w '%{http_code}' -o /dev/null -s -k https://"${DERP_HOSTNAME}"/derp/probe -m "${CURL_TIMEOUT:-2}")
if [ $? -ne 0 ]; then
  echo "Error: curl failed"
  exit 1
fi

if [[ "$response" -lt "200" ]] || [[ "$response" -ge "400" ]]; then
    echo "failed curl for ${PROBE_ADDRESS} with response $response" >&2
    exit 1
fi

/app/derpprobe --derp-map file:///app/derpmap.json  --once

if [ $? -ne 0 ]; then
  echo "Error: derpprobe failed"
  exit 1
fi
