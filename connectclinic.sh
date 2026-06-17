#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/clinic.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ clinic.env not found. Copy clinic.env.example and edit it."
    exit 1
fi
source "$ENV_FILE"

# ---- Helper: find a node (source or sink) by keyword ----
find_node() {
    local keyword="$1"
    local type="$2"   # "source" or "sink"
    pactl list "$type" short | awk '{print $2}' | while read -r name; do
        if pactl list "$type" | grep -A30 "Name: $name" | grep -qi "$keyword"; then
            echo "$name"
            return 0
        fi
    done
    return 1
}

# ---- Helper: get monitor name of a sink ----
monitor_of() {
    echo "${1}.monitor"
}

# ---- Cleanup on exit ----
cleanup() {
    echo -e "\nStopping all loopbacks..."
    if [ -f /tmp/clinic_loopback_pids ]; then
        while read -r pid; do
            kill "$pid" 2>/dev/null || true
        done < /tmp/clinic_loopback_pids
        rm -f /tmp/clinic_loopback_pids
    fi
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

# ---- 1. Create the null sink if missing ----
if ! pactl list sinks short | grep -q "$SCRIBE_SINK"; then
    echo "Creating virtual sink $SCRIBE_SINK..."
    pactl load-module module-null-sink \
        sink_name="$SCRIBE_SINK" \
        sink_properties="device.description=$SCRIBE_SINK"
    sleep 1
fi

# ---- 2. Discover devices ----
echo "Discovering audio devices..."

# Headset microphone (source)
HEADSET_MIC=$(find_node "$HEADSET_NAME" source)
if [ -z "$HEADSET_MIC" ]; then
    echo "❌ Headset microphone not found (keyword: $HEADSET_NAME)"
    exit 1
fi
echo "  Mic: $HEADSET_MIC"

# Headset output (sink)
HEADSET_OUT=$(find_node "$HEADSET_NAME" sink)
if [ -z "$HEADSET_OUT" ]; then
    echo "❌ Headset sink not found (keyword: $HEADSET_NAME)"
    exit 1
fi
echo "  Headphones: $HEADSET_OUT"

# Zoom output sink
ZOOM_SINK=$(find_node "$ZOOM_NAME" sink)
if [ -z "$ZOOM_SINK" ]; then
    echo "❌ Zoom sink not found (keyword: $ZOOM_NAME). Is Zoom running in a call?"
    exit 1
fi
echo "  Zoom sink: $ZOOM_SINK"
ZOOM_MONITOR=$(monitor_of "$ZOOM_SINK")

# Chrome input – try exact name first, then fallback to search
CHROME_INPUT=""
if [ -n "$CHROME_INPUT_NAME" ]; then
    # Check if the exact node exists (as a source)
    if pactl list sources short | awk '{print $2}' | grep -q "^$CHROME_INPUT_NAME$"; then
        CHROME_INPUT="$CHROME_INPUT_NAME"
    fi
fi
if [ -z "$CHROME_INPUT" ]; then
    echo "⏳ Exact Chrome input not found, searching by app name '$CHROME_NAME'..."
    CHROME_INPUT=$(find_node "$CHROME_NAME" source)
fi

# If still not found, wait a bit (user may start recording after script)
if [ -z "$CHROME_INPUT" ]; then
    echo "⏳ Chrome input not yet visible. Start OpenEvidence recording now."
    for i in {1..15}; do
        sleep 1
        if [ -n "$CHROME_INPUT_NAME" ]; then
            if pactl list sources short | awk '{print $2}' | grep -q "^$CHROME_INPUT_NAME$"; then
                CHROME_INPUT="$CHROME_INPUT_NAME"
                break
            fi
        else
            CHROME_INPUT=$(find_node "$CHROME_NAME" source)
            [ -n "$CHROME_INPUT" ] && break
        fi
        echo -n "."
    done
    echo
fi

if [ -z "$CHROME_INPUT" ]; then
    echo "❌ Chrome input not found after waiting. Please start recording and rerun."
    exit 1
fi
echo "  Chrome input: $CHROME_INPUT"

SCRIBE_MONITOR=$(monitor_of "$SCRIBE_SINK")

# ---- 3. Create all loopback connections ----
PID_FILE="/tmp/clinic_loopback_pids"
rm -f "$PID_FILE"
touch "$PID_FILE"

# Helper: start a loopback and save its PID
start_loop() {
    local source="$1"
    local target="$2"
    pw-loopback --source "$source" --target "$target" &
    local pid=$!
    echo "$pid" >> "$PID_FILE"
}

echo "Creating audio routes..."

# Mic → Scribe (left + right)
start_loop "$HEADSET_MIC" "$SCRIBE_SINK:playback_FL"
start_loop "$HEADSET_MIC" "$SCRIBE_SINK:playback_FR"
echo "  ✔ Mic → Scribe"

# Zoom → Scribe (left + right)
start_loop "$ZOOM_MONITOR" "$SCRIBE_SINK:playback_FL"
start_loop "$ZOOM_MONITOR" "$SCRIBE_SINK:playback_FR"
echo "  ✔ Zoom → Scribe"

# Zoom → Headphones (left + right) – so you hear the remote party
start_loop "$ZOOM_MONITOR" "$HEADSET_OUT:playback_FL"
start_loop "$ZOOM_MONITOR" "$HEADSET_OUT:playback_FR"
echo "  ✔ Zoom → Headphones"

# Scribe (mixed mic+Zoom) → Chrome input
start_loop "$SCRIBE_MONITOR" "$CHROME_INPUT"
echo "  ✔ Scribe → Chrome"

echo
echo "✅ Audio routing is active."
echo "   - Chrome hears: your mic + remote speaker"
echo "   - You hear: remote speaker (through headset)"
echo "   - System sounds are NOT routed to Chrome"
echo
echo "Press Ctrl+C to stop all routes and clean up."

# Keep script running until user hits Ctrl+C
wait
