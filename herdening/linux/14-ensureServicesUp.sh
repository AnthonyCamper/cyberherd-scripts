#!/bin/bash

# USAGE
# sudo ./restart_services.sh httpd sshd apache2
# Ensure the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

while true; do
  # Loop through all arguments passed to the script
  for service in "$@"; do
    # Check if the service is active
    systemctl is-active --quiet "$service"
    status=$?

    if [ $status -ne 0 ]; then
      echo "Service $service is stopped. Attempting to restart..."
      # Attempt to restart the service
      systemctl restart "$service"
      restart_status=$?

      if [ $restart_status -eq 0 ]; then
        echo "Service $service restarted successfully."
      else
        echo "Failed to restart service $service."
      fi
    else
      echo "Service $service is already running."
    fi
  done

  # Wait for 30 seconds before the next iteration
  sleep 30
done

