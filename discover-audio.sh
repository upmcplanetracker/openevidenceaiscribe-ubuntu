#!/bin/bash

echo "===== AUDIO DEVICE DISCOVERY ====="
echo

echo "--- Sinks (outputs / speakers / headphones) ---"
pactl list sinks short | awk '{print $2}' | while read -r sink; do
    desc=$(pactl list sinks | grep -A20 "Name: $sink" | grep "device.description" | head -n1 | cut -d'"' -f2)
    echo "  $sink  ->  $desc"
done
echo

echo "--- Sources (inputs / microphones) ---"
pactl list sources short | awk '{print $2}' | while read -r src; do
    desc=$(pactl list sources | grep -A20 "Name: $src" | grep "device.description" | head -n1 | cut -d'"' -f2)
    echo "  $src  ->  $desc"
done
echo

echo "--- PipeWire node names (for CHROME_INPUT_NAME) ---"
pw-cli list-objects | grep -E "node.name|node.description" | grep -i "chrome" -A1 || echo "  (No Chrome nodes found – start OpenEvidence recording first)"
echo

echo "Tip: Look for 'ZOOM VoiceEngine' (sink) and your headset's sink/source."
