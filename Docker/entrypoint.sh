#!/bin/bash
set -euo pipefail

# Initialize the commands with the executables
DERP_CMD=(/usr/local/bin/derper)
TSD_CMD=(/usr/local/bin/tailscaled)
TS_CMD=(/usr/local/bin/tailscale up)

# Generate derpmap
jq -n --arg hostname "${DERP_HOSTNAME:-}" '{"Regions":{"900":{"RegionID":900,"Nodes":[{"Name":"900","HostName":$hostname}]}}}' > /app/derpmap.json

# Translate every DERP_*, TSD_*, and TS_* environment variable into a flag on
# the matching binary. Read NUL-delimited name=value pairs from `env -0` so that
# values containing spaces or newlines are preserved verbatim (a plain
# `for VAR in $(env)` word-splits on whitespace and corrupts such values).
while IFS='=' read -r -d '' VAR_NAME VAR_VALUE; do
  case "$VAR_NAME" in
    DERP_*|TSD_*|TS_*) ;;
    *) continue ;;
  esac

  # Convert the variable name to an argument name:
  # strip the prefix, replace underscores with dashes, and convert to lowercase.
  ARG_NAME=$(echo "$VAR_NAME" | sed -E 's/^(DERP_|TSD_|TS_)//; s/_/-/g; y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/')

  # Append the argument to the matching command.
  case "$VAR_NAME" in
    DERP_*)
      DERP_CMD+=("--$ARG_NAME=$VAR_VALUE")
      echo "Adding $ARG_NAME=$VAR_VALUE to DERP_CMD"
      ;;
    TSD_*)
      TSD_CMD+=("--$ARG_NAME=$VAR_VALUE")
      echo "Adding $ARG_NAME=$VAR_VALUE to TSD_CMD"
      ;;
    TS_*)
      TS_CMD+=("--$ARG_NAME=$VAR_VALUE")
      # We don't want to log the auth key
      echo "Adding $ARG_NAME to TS_CMD"
      ;;
  esac
done < <(env -0)

# Start tailscaled and call tailscale up if we need to verify clients
if [[ ${DERP_VERIFY_CLIENTS:-} == "true" && ${CONTAINERBOOT:-} == "false" ]]; then
  # Start and background tailscaled
  setsid "${TSD_CMD[@]}" > /dev/stdout 2> /dev/stderr &
  # Start and background tailscale up
  setsid "${TS_CMD[@]}" > /dev/stdout 2> /dev/stderr &
fi

# Execute the derper
exec "${DERP_CMD[@]}"
