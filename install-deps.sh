#!/bin/bash
set -e

echo "--- Checking Clinic Audio Router dependencies ---"

REQUIRED_CMDS=(pw-link pactl grep awk)

MISSING=false
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ Missing command: $cmd"
        MISSING=true
    fi
done

if [ "$MISSING" = true ]; then
    echo
    echo "Installing required packages..."
    sudo apt update
    sudo apt install -y \
        pipewire \
        pipewire-pulse \
        pipewire-audio-client-libraries \
        wireplumber \
        pavucontrol
else
    echo "✔ All required commands present."
fi

echo
echo "PipeWire status:"
systemctl --user status pipewire --no-pager || true
systemctl --user status wireplumber --no-pager || true

echo "--- Dependency check complete ---"
