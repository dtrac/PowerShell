#!/bin/bash

# Define the file path and content
FILE_PATH="/etc/custom-file.txt"
FILE_CONTENT="This is a test file created by the Azure Custom Script Extension."

# Write the content to the file
echo "$FILE_CONTENT" > "$FILE_PATH"

# Change ownership and permissions (optional)
chmod 644 "$FILE_PATH"
chown root:root "$FILE_PATH"

# Log the action
echo "File created at $FILE_PATH with content: $FILE_CONTENT"