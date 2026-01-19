Clinic Audio Router (Ubuntu / PipeWire)
=======================================

Route Zoom and headset audio into Google Chrome so **OpenEvidence AI** can transcribe meetings, while still keeping audio in your headphones.
This project provides shell scripts to temporarily rewire PipeWire audio connections for clinical documentation workflows.
* * *

What This Does
--------------
*   Duplicates out your headset microphone so multiple applications can use it at once
*   Mixes Zoom audio and microphone audio into a virtual sink
*   Feeds that virtual sink into Chrome as a microphone so OpenEvidence AI can hear all speakers without feedback loops
*   Keeps Zoom and Chrome audio playing in your headphones
* * *

Tested On
---------
*   Ubuntu 25.10
*   PipeWire with WirePlumber
*   Google Chrome (apt package)
*   Zoom Desktop Client (Flatpak)
*   Jabra USB headset
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

    git clone https://github.com/upmcplanetracker/openevidenceaiscribe-ubuntu.git
    cd openevidenceaiscribe-ubuntu
    chmod +x *.sh
    ./install-deps.sh
    
* * *

Configure Audio Devices
-----------------------
### 1\. Discover device names

    ./discover-audio.sh
    
Use the output to confirm headset, Zoom, and Chrome PipeWire node names. Use these device names in step 2.

### 2\. Create your config file

    cp clinic.env.example clinic.env
    nano clinic.env
    
Edit the values so they match your hardware and applications.
* * *

Usage
-----
### Turn Audio Routing ON

    ./connectclinic.sh
    
**Important:** Start OpenEvidence recording in Chrome and a Zoom meeting window before running this script. The Chrome and Zoom input most likely does not exist until recording begins.  If you close either Zoom or the OpenEvidence recording while the shell connectclinic.sh is running, you will probably need to run this script again (i.e., you will need to run the connectclinic.sh script before each patient with Zoom meeting open and the OpenEvidence tab open and recording.  Unforutnaely Ubuntu is aggressive about re-wiring the audio once a device shuts off.)

### Turn Audio Routing OFF

    ./disconnectclinic.sh
    
This restores normal audio behavior.
* * *

Optional: Bash Aliases
----------------------
Edit your `~/.bashrc` file:

    nano ~/.bashrc
    
Add the following lines to the bottom of the file:

    alias clinic-on="$HOME/openevidenceaiscribe-ubuntu/connectclinic.sh"
    alias clinic-off="$HOME/openevidenceaiscribe-ubuntu/disconnectclinic.sh"
    
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
    
Log out and log back in to enable the tray icon.  You will need to manually run the Sound Switcher once to get it started. When this is working your input should be your microphone and the output should be the AI scribe.  You may need to double check this setting every time you run the connect script.

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

I am not affiliated with Zoom, Chrome/Google, OpenEvidence, or anything else used here.

Remember to make sure your version of Zoom is HIPAA compliant/has a BAA. 
