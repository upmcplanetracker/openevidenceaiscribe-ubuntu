#!/bin/bash
set -e

echo "--- Checking Clinic Audio Router dependencies ---"

REQUIRED_CMDS=(pw-link pactl pw-loopback)
MISSING=()

for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo "❌ Missing commands: ${MISSING[*]}"
    echo "Installing required packages..."
    sudo apt update
    sudo apt install -y \
        pipewire \
        pipewire-pulse \
        pipewire-bin \
        wireplumber \
        pavucontrol \
        pipewire-audio-client-libraries \
        pulseaudio-utils            # <--- THIS WAS MISSING
else
    echo "✔ All required commands already present."
fi

# ---- Double‑check ----
echo
echo "--- Verifying installation ---"
ALL_OK=true
for cmd in "${REQUIRED_CMDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  ✔ $cmd found"
    else
        echo "  ❌ $cmd still missing (unexpected)"
        ALL_OK=false
    fi
done

echo
echo "--- Service status ---"
systemctl --user status pipewire --no-pager | head -n 3
systemctl --user status wireplumber --no-pager | head -n 3

echo
if [ "$ALL_OK" = true ]; then
    echo "✅ All dependencies are installed and available."
    echo
    echo "ℹ️  If you see a 'libcamera' warning above, ignore it –"
    echo "   that's only for webcams and does NOT affect audio routing."
    echo
    echo "🚀 Next step: configure your audio devices."
    echo "   Run: ./discover-audio.sh"
    echo "   Then edit clinic.env with the device names you find."
else
    echo "❌ Some dependencies are still missing."
    echo "   Please try running this script again, or install manually:"
    echo "   sudo apt install pulseaudio-utils pipewire-pulse pipewire-bin wireplumber pavucontrol"
    exit 1
fi

echo "--- Done ---"
