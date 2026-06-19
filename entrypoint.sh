#!/bin/bash
set -e

CONFIG_FILE="/home/ciphernode/.config/interfold/config.yaml"
SECRETS_FILE="/run/secrets/secrets.json"

if [ ! -f "$SECRETS_FILE" ]; then
    echo "Error: Secrets file $SECRETS_FILE not found!"
    exit 1
fi

PRIVATE_KEY=$(jq -r '.private_key' "$SECRETS_FILE")
PASSWORD=$(jq -r '.password' "$SECRETS_FILE")

echo "Setting password"
interfold password set --config "$CONFIG_FILE" --password "$PASSWORD" 2>/dev/null || \
interfold password set --config "$CONFIG_FILE" --password "$PASSWORD" --overwrite 2>/dev/null || true

echo "Setting wallet key"
interfold wallet set --config "$CONFIG_FILE" --private-key "$PRIVATE_KEY" 2>/dev/null || true

echo "Starting ciphernode"
exec interfold start -v --config "$CONFIG_FILE"
