#!/bin/bash

# Define the paths to search in
search_paths=("/etc" "/home" "/var" "/root") # Array of paths

# Loop through each path and perform the searches
for path in "${search_paths[@]}"; do
    echo "Searching in $path for SSNs..."
    grep -rE "[0-9]{3}-[0-9]{2}-[0-9]{4}" "$path"

    echo "Searching in $path for credit card numbers..."
    grep -rE "([0-9]{4}[- ]){3}[0-9]{4}" "$path"
done
