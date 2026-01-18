#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/clinic.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ clinic.env not found."
    echo "Copy clinic.env.example to clinic.env and edit it first."
    exit 1
fi

source "$ENV_FILE"

echo "--- Starting Clinic Audio Router ---"

# Unmute virtual sink just in case
pactl set-sink-mute "$SCRIBE_SINK" 0 2>/dev/null || true

# Create virtual sink if missing
if ! pactl list sinks short | grep -q "$SCRIBE_SINK"; then
    echo "Creating Scribe virtual sink..."
    pactl load-module module-null-sink \
        sink_name="$SCRIBE_SINK" \
        sink_properties=device.description="Scribe_AI_Input"
    sleep 1
fi

# Device discovery
JABRA_MIC=$(pw-link -o | grep -i "$HEADSET_NAME" | grep capture | head -n 1)
JABRA_OUT_FL=$(pw-link -i | grep -i "$HEADSET_NAME" | grep playback_FL | head -n 1)
JABRA_OUT_FR=$(pw-link -i | grep -i "$HEADSET_NAME" | grep playback_FR | head -n 1)

ZOOM_OUT_FL=$(pw-link -o | grep "$ZOOM_NAME:output_FL" || true)
ZOOM_OUT_FR=$(pw-link -o | grep "$ZOOM_NAME:output_FR" || true)

CHROME_IN=$(pw-link -i | grep "$CHROME_INPUT_NAME" || true)

SCRIBE_MON_FL="$SCRIBE_SINK:monitor_FL"
SCRIBE_MON_FR="$SCRIBE_SINK:monitor_FR"

# Mic -> Scribe
if [ -n "$JABRA_MIC" ]; then
    pw-link "$JABRA_MIC" "$SCRIBE_SINK:playback_FL" 2>/dev/null
    pw-link "$JABRA_MIC" "$SCRIBE_SINK:playback_FR" 2>/dev/null
    echo "✔ Mic -> Scribe"
fi

# Zoom -> Scribe
if [ -n "$ZOOM_OUT_FL" ]; then
    pw-link "$ZOOM_OUT_FL" "$SCRIBE_SINK:playback_FL" 2>/dev/null
    pw-link "$ZOOM_OUT_FR" "$SCRIBE_SINK:playback_FR" 2>/dev/null
    echo "✔ Zoom -> Scribe"
fi

# Zoom -> Headphones
if [ -n "$ZOOM_OUT_FL" ] && [ -n "$JABRA_OUT_FL" ]; then
    pw-link "$ZOOM_OUT_FL" "$JABRA_OUT_FL" 2>/dev/null
    pw-link "$ZOOM_OUT_FR" "$JABRA_OUT_FR" 2>/dev/null
    echo "✔ Zoom -> Headphones"
fi

# Scribe -> Chrome
if [ -n "$CHROME_IN" ]; then
    pw-link "$SCRIBE_MON_FL" "$CHROME_IN" 2>/dev/null
    pw-link "$SCRIBE_MON_FR" "$CHROME_IN" 2>/dev/null
    echo "✔ Scribe -> Chrome"
else
    echo "❌ Chrome input not found."
    echo "Start OpenEvidence recording, then rerun."
fi

echo "--- Audio routing active ---"
