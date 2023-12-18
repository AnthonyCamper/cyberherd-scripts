#!/usr/bin/env bash

# HANDLING
# SETUID
# BINARIES

# Define the list of binaries to exclude from removal of setuid
EXCLUDES=("binary1" "binary2" "binary3")

# Convert EXCLUDES array into a pattern string
EXCLUDE_PATTERN=$(printf "|%s" "${EXCLUDES[@]}")
EXCLUDE_PATTERN=${EXCLUDE_PATTERN:1}

# Find all setuid binaries
find / -type f -perm -4000 2>/dev/null | while read -r file; do
    # Check if the file is in the exclusion list
    if ! grep -E -q "(^|/)$EXCLUDE_PATTERN$" <<< "$file"; then
        # Remove the setuid bit
        chmod u-s "$file"
        echo "Removed setuid from $file"
    else
        echo "Skipped excluded file $file"
    fi
done
