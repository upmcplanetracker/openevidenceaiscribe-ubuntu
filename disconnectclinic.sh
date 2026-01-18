#!/bin/bash

echo "--- Resetting Clinic Audio ---"

# Remove all manual PipeWire links
pw-link -d -a 2>/dev/null
echo "✔ Removed manual PipeWire links"

# Remove virtual sink
SCRIBE_ID=$(pactl list short modules | grep "module-null-sink.*Scribe_Mixer" | awk '{print $1}')

if [ -n "$SCRIBE_ID" ]; then
    pactl unload-module "$SCRIBE_ID"
    echo "✔ Removed Scribe_Mixer"
else
    echo "ℹ Scribe_Mixer not present"
fi

# Restore headset as default (best effort)
DEFAULT_SINK=$(pactl list short sinks | grep -i Jabra | awk '{print $2}' | head -n 1)
DEFAULT_SOURCE=$(pactl list short sources | grep -i Jabra | awk '{print $2}' | head -n 1)

[ -n "$DEFAULT_SINK" ] && pactl set-default-sink "$DEFAULT_SINK"
[ -n "$DEFAULT_SOURCE" ] && pactl set-default-source "$DEFAULT_SOURCE"

echo "--- Audio reset complete ---"
