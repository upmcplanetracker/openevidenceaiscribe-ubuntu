 Clinic Audio Router (Ubuntu / PipeWire) body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Ubuntu, Cantarell, "Helvetica Neue", Arial, sans-serif; line-height: 1.6; max-width: 900px; margin: 40px auto; padding: 0 20px; } pre { background: #f6f8fa; padding: 12px; overflow-x: auto; border-radius: 6px; } code { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; } h1, h2, h3 { margin-top: 1.5em; } ul { margin-left: 1.5em; }

Clinic Audio Router (Ubuntu / PipeWire)
=======================================

Route Zoom and headset audio into Google Chrome so **OpenEvidence AI** can transcribe meetings, while still keeping audio in your headphones.

This project provides shell scripts to temporarily rewire PipeWire audio connections for clinical documentation workflows.

* * *

What This Does
--------------

*   Fans out your headset microphone
*   Mixes Zoom audio and microphone audio into a virtual sink
*   Feeds that virtual sink into Chrome as a microphone
*   Keeps Zoom and Chrome audio playing in your headphones
*   Allows OpenEvidence AI to hear everything without feedback loops

* * *

Tested On
---------

*   Ubuntu 22.04+
*   PipeWire with WirePlumber
*   Google Chrome
*   Zoom Desktop Client
*   Jabra USB / Bluetooth headsets (others should work with configuration changes)

* * *

Requirements
------------

*   Ubuntu with PipeWire (default on 22.04+)
*   `pw-link`
*   `pactl`
*   Zoom Desktop Client
*   Google Chrome

* * *

Installation
------------

Clone the repository and install dependencies:

    git clone https://github.com/YOURNAME/clinic-audio-router.git
    cd clinic-audio-router
    chmod +x *.sh
    ./install-deps.sh
    

* * *

Configure Audio Devices
-----------------------

### 1\. Create your config file

    cp clinic.env.example clinic.env
    nano clinic.env
    

Edit the values so they match your hardware and applications.

### 2\. Discover device names

    ./discover-audio.sh
    

Use the output to confirm headset, Zoom, and Chrome PipeWire node names. Update `clinic.env` if needed.

* * *

Usage
-----

### Turn Audio Routing ON

    ./connectclinic.sh
    

**Important:** Start OpenEvidence recording in Chrome before running this script. The Chrome input does not exist until recording begins.

### Turn Audio Routing OFF

    ./disconnectclinic.sh
    

This restores normal audio behavior.

* * *

Optional: Bash Aliases
----------------------

Edit your `~/.bashrc` file:

    nano ~/.bashrc
    

Add the following lines:

    alias clinic-on="$HOME/clinic-audio-router/connectclinic.sh"
    alias clinic-off="$HOME/clinic-audio-router/disconnectclinic.sh"
    

Reload your shell configuration:

    source ~/.bashrc
    

You can now use:

    clinic-on
    clinic-off
    

* * *

Optional: Sound Switcher Indicator
----------------------------------

This provides a tray icon for quickly switching audio devices.

    sudo snap install indicator-sound-switcher
    sudo apt install gnome-shell-extension-appindicator
    

Log out and log back in to enable the tray icon.

* * *

Troubleshooting
---------------

*   Chrome input only appears while recording is active
*   Make sure Zoom is not muted
*   Re-run device discovery if names change

    ./discover-audio.sh
    

Check PipeWire status:

    systemctl --user status pipewire wireplumber
    

* * *

Disclaimer
----------

This project uses low-level PipeWire links. Audio routing may break after:

*   Operating system upgrades
*   PipeWire or WirePlumber updates
*   Major Zoom or Chrome updates

Use at your own risk.
