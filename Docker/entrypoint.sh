#!/bin/bash

# Initialize the command with the executable
CMD="/app/derper"

# Generate derpmap
jq -n --arg hostname "${DERP_HOSTNAME}" '{"Regions":{"900":{"RegionID":900,"Nodes":[{"Name":"900","HostName":$hostname}]}}}' > /app/derpmap.json

# Loop through all environment variables
for VAR in $(env); do
  # Check if the variable starts with DERP_
  if [[ $VAR == DERP_* ]]; then
    # Extract the name and value
    VAR_NAME=$(echo "$VAR" | cut -d= -f1)
    VAR_VALUE=$(echo "$VAR" | cut -d= -f2-)

    # Convert the variable name to lowercase and replace underscores with hyphens
    ARG_NAME=$(echo "$VAR_NAME" | sed 's/^DERP_//' | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    
    # Append the argument to the command
    CMD="$CMD --$ARG_NAME=$VAR_VALUE"
  fi
done

# Execute the command
exec $CMD
