#!/bin/bash

echo "===== PIPEWIRE AUDIO DISCOVERY ====="
echo

echo "--- Sources (capture / microphones) ---"
pw-link -o | grep capture || true
echo

echo "--- Sink inputs (headphones / speakers) ---"
pw-link -i | grep playback || true
echo

echo "--- Outputs (apps producing audio) ---"
pw-link -o | grep output || true
echo

echo "--- pactl sources ---"
pactl list short sources
echo

echo "--- pactl sinks ---"
pactl list short sinks
echo
