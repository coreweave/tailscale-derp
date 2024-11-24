#!/bin/bash

# Initialize the commands with the executables
DERP_CMD="/usr/local/bin/derper"
TSD_CMD="/usr/local/bin/tailscaled"
TS_CMD="/usr/local/bin/tailscale up"

# Generate derpmap
jq -n --arg hostname "${DERP_HOSTNAME}" '{"Regions":{"900":{"RegionID":900,"Nodes":[{"Name":"900","HostName":$hostname}]}}}' > /app/derpmap.json

# Loop through all environment variables
for VAR in $(env); do
  # Check if the variable starts with DERP_, TSD_, or TS_
  case "$VAR" in
    DERP_*|TSD_*|TS_*)
      # Extract the name and value
      VAR_NAME=$(echo "$VAR" | cut -d= -f1)
      VAR_VALUE=$(echo "$VAR" | cut -d= -f2-)

      # Convert the variable name to an argument name
      # Remove the prefix, replace underscores with dashes, and convert to lowercase
      ARG_NAME=$(echo "$VAR_NAME" | sed -E 's/^(DERP_|TSD_|TS_)//; s/_/-/g; y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/')
      
      # Append the argument to command based on argument name
      case "$VAR_NAME" in
        DERP_*)
          DERP_CMD="$DERP_CMD --$ARG_NAME=$VAR_VALUE"
          echo "Adding $ARG_NAME=$VAR_VALUE to DERP_CMD"
          ;;
        TSD_*)
          TSD_CMD="$TSD_CMD --$ARG_NAME=$VAR_VALUE"
          echo "Adding $ARG_NAME=$VAR_VALUE to TSD_CMD"
          ;;
        TS_*)
          TS_CMD="$TS_CMD --$ARG_NAME=$VAR_VALUE"
          # We don't want to log the auth key
          echo "Adding $ARG_NAME to TS_CMD"
          ;;
      esac
      ;;
  esac

done

# Start tailscaled and call tailscale up if we need to verify clients
if [[ $DERP_VERIFY_CLIENTS == "true" && $CONTAINERBOOT == "false" ]]; then
  # Start and background tailscaled
  setsid $TSD_CMD > /dev/stdout 2> /dev/stderr &
  # Start and background tailscale up
  setsid $TS_CMD > /dev/stdout 2> /dev/stderr &
fi

# Execute the derper
exec $DERP_CMD
