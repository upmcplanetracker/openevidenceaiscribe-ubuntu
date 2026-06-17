<h1>🎧 Clinic Audio Router <span style="font-weight:400; font-size:1.2rem;">· Ubuntu / PipeWire</span></h1>

<p>Route Zoom and headset audio into Google Chrome so <strong>OpenEvidence AI</strong> can transcribe meetings, while still keeping audio in your headphones.<br>
This project provides shell scripts to safely rewire PipeWire audio for clinical documentation workflows.</p>

<hr>

<h2>📦 What This Does</h2>
<ul>
    <li>Duplicates your headset microphone so multiple apps can use it at once</li>
    <li>Mixes <strong>Zoom audio</strong> + <strong>your microphone</strong> into a virtual sink</li>
    <li>Feeds that mixed audio into Chrome as a microphone → OpenEvidence hears <strong>both</strong> sides of the conversation</li>
    <li>Keeps Zoom and Chrome audio playing normally in your headphones</li>
    <li><strong>Blocks system sounds</strong> (beeps, notifications, music) from ever reaching Chrome</li>
</ul>

<hr>

<h2>✅ Tested On</h2>
<ul>
    <li><strong>Ubuntu 26.04</strong> (also works on 22.04–25.10)</li>
    <li>PipeWire with WirePlumber</li>
    <li>Google Chrome (apt or Snap)</li>
    <li>Zoom Desktop Client (Flatpak or .deb)</li>
    <li>Jabra / Logitech / Plantronics USB headsets</li>
</ul>

<hr>

<h2>📋 Requirements</h2>
<ul>
    <li>Ubuntu with PipeWire (default on 22.04+)</li>
    <li><code>pw-link</code>, <code>pactl</code>, and <strong><code>pw-loopback</code></strong> (installed by our script)</li>
    <li>Zoom Desktop Client</li>
    <li>Google Chrome</li>
</ul>

<hr>

<h2>🚀 First‑Time Setup <span style="font-weight:400;">(do this once)</span></h2>

<h3>1. Clone the repository</h3>
<pre><code>git clone https://github.com/upmcplanetracker/openevidenceaiscribe-ubuntu.git
cd openevidenceaiscribe-ubuntu</code></pre>

<h3>2. Make all scripts executable</h3>
<pre><code>chmod +x *.sh</code></pre>

<h3>3. Install dependencies</h3>
<pre><code>./install-deps.sh</code></pre>
<p>This installs PipeWire tools and checks that everything is running correctly.</p>

<hr>

<h2>⚙️ Configure Audio Devices <span style="font-weight:400;">(do this once)</span></h2>

<h3>Step 1: Discover your device names</h3>
<pre><code>./discover-audio.sh</code></pre>
<p>You'll see output like:</p>
<pre><code>--- Sinks (outputs) ---
  alsa_output.usb-Jabra...  ->  Jabra Evolve 65
  ZOOM VoiceEngine          ->  Zoom Audio Output

--- Sources (microphones) ---
  alsa_input.usb-Jabra...   ->  Jabra Evolve 65
  Chrome input:input_MONO   ->  Google Chrome (only appears while recording)</code></pre>
<p><strong>Write down</strong> the unique keywords for:</p>
<ul>
    <li>Your <strong>headset</strong> (e.g., <code>Jabra</code>)</li>
    <li><strong>Zoom</strong> (e.g., <code>ZOOM VoiceEngine</code>)</li>
    <li><strong>Chrome's input</strong> (e.g., <code>Chrome input:input_MONO</code>) – this only appears when OpenEvidence is <em>actively recording</em>.</li>
</ul>

<h3>Step 2: Create and edit your config file</h3>
<pre><code>cp clinic.env.example clinic.env
nano clinic.env</code></pre>
<p>Fill in the values using the keywords you just discovered.<br>
Example:</p>
<pre><code>HEADSET_NAME="Jabra"
ZOOM_NAME="ZOOM VoiceEngine"
CHROME_NAME="Google Chrome"
CHROME_INPUT_NAME="Chrome input:input_MONO"
SCRIBE_SINK="Scribe_Mixer"</code></pre>

<div class="tip">
    <strong>💡 Tip:</strong><br>
    • <code>CHROME_INPUT_NAME</code> is optional – if you leave it blank, the script will search for Chrome by <code>CHROME_NAME</code>.<br>
    • But setting the exact name (from <code>discover-audio.sh</code>) is faster and more reliable.
</div>

<p>Save and close (<code>Ctrl+O</code>, <code>Enter</code>, <code>Ctrl+X</code>).</p>

<hr>

<h2>🔄 Everyday Usage <span style="font-weight:400;">(before each patient)</span></h2>

<p>You'll run these two scripts <strong>every time</strong> you start a new telemedicine session.</p>

<h3>✅ Turn Audio Routing ON</h3>

<h4>1. Start your Zoom call</h4>
<p>Join the meeting as usual.<br>
<em>(You can be muted or unmuted – it doesn't matter.)</em></p>

<h4>2. Open Chrome and navigate to OpenEvidence</h4>
<p>Get the AI scribe page ready, but <strong>DO NOT start recording yet</strong>.</p>

<h4>3. Run the connect script</h4>
<pre><code>./connectclinic.sh</code></pre>
<p>You'll see something like:</p>
<pre><code>Discovering audio devices...
  Mic: alsa_input.usb-Jabra...
  Headphones: alsa_output.usb-Jabra...
  Zoom sink: ZOOM VoiceEngine
⏳ Chrome input not yet visible. Start OpenEvidence recording now.
.....
  Chrome input: Chrome input:input_MONO
Creating audio routes...
  ✔ Mic → Scribe
  ✔ Zoom → Scribe
  ✔ Zoom → Headphones
  ✔ Scribe → Chrome

✅ Audio routing is active.
   - Chrome hears: your mic + remote speaker
   - You hear: remote speaker (through headset)
   - System sounds are NOT routed to Chrome

Press Ctrl+C to stop all routes and clean up.</code></pre>

<h4>4. Now start the OpenEvidence recording</h4>
<p>The script is already running and waiting – as soon as Chrome's input appears, it connects automatically.<br>
<em>(You'll see the dots appear while it waits – that's normal.)</em></p>

<p>✅ <strong>That's it!</strong> OpenEvidence now hears both you and the patient clearly, and you hear the patient through your headset.</p>

<hr>

<h3>❌ Turn Audio Routing OFF</h3>

<p>When the call is over, you have <strong>two easy options</strong>:</p>

<h4>Option A: Press <code>Ctrl+C</code> in the terminal where <code>connectclinic.sh</code> is running</h4>
<p>The script will clean up all audio routes and exit.</p>

<h4>Option B: Open a <strong>new terminal</strong> and run:</h4>
<pre><code>./disconnectclinic.sh</code></pre>
<p>This stops all routes without needing the original terminal.</p>

<hr>

<h2>🧠 Why this is better than before</h2>

<table>
    <thead>
        <tr><th>Old script</th><th>New script</th></tr>
    </thead>
    <tbody>
        <tr><td>Had to start Chrome <em>before</em> running the script</td><td>You can run the script <em>first</em> – it waits for Chrome to appear</td></tr>
        <tr><td>Broke if Zoom or Chrome restarted</td><td><code>pw-loopback</code> auto‑reconnects when apps restart</td></tr>
        <tr><td>Required rerunning before <em>every</em> patient</td><td>Run once per session – stays active until you stop it</td></tr>
        <tr><td>System sounds sometimes leaked</td><td><strong>Guaranteed</strong> isolation – Chrome only hears mic + Zoom</td></tr>
    </tbody>
</table>

<hr>

<h2>⌨️ Optional: Bash Aliases <span style="font-weight:400;">(saves typing)</span></h2>

<p>Edit your <code>~/.bashrc</code>:</p>
<pre><code>nano ~/.bashrc</code></pre>
<p>Add these lines at the bottom:</p>
<pre><code>alias clinic-on="$HOME/openevidenceaiscribe-ubuntu/connectclinic.sh"
alias clinic-off="$HOME/openevidenceaiscribe-ubuntu/disconnectclinic.sh"</code></pre>
<p>Reload:</p>
<pre><code>source ~/.bashrc</code></pre>
<p>Now you can just type:</p>
<pre><code>clinic-on
clinic-off</code></pre>

<hr>

<h2>🖥️ Optional: Sound Switcher Indicator <span style="font-weight:400;">(handy for checking)</span></h2>

<p>This gives you a tray icon to quickly see/change your default input/output devices.</p>
<pre><code>sudo snap install indicator-sound-switcher
sudo apt install gnome-shell-extension-appindicator</code></pre>
<p><strong>Log out and back in</strong> to see the icon.<br>
You don't <em>need</em> this – the script handles routing automatically – but it's useful to verify that your headset is still the default system device.</p>

<hr>

<h2>🔧 Troubleshooting</h2>

<h3>“Chrome input not found” even after waiting</h3>
<ul>
    <li>Make sure you've <strong>started the recording</strong> in OpenEvidence <em>while</em> <code>connectclinic.sh</code> is running.</li>
    <li>The script waits up to <strong>15 seconds</strong> – if it times out, just run <code>./connectclinic.sh</code> again after recording has started.</li>
</ul>

<h3>Audio stops working after Zoom mutes/unmutes</h3>
<ul>
    <li><code>pw-loopback</code> automatically reconnects. If it doesn't, press <code>Ctrl+C</code> and rerun <code>./connectclinic.sh</code>.</li>
</ul>

<h3>Device names changed after an update</h3>
<ul>
    <li>Re‑run <code>./discover-audio.sh</code> and update your <code>clinic.env</code> file.</li>
</ul>

<h3>Check if PipeWire is healthy</h3>
<pre><code>systemctl --user status pipewire wireplumber</code></pre>

<h3>I hear an echo or feedback</h3>
<ul>
    <li>Make sure you <strong>aren't</strong> routing Chrome's <em>output</em> back into the Scribe sink.</li>
    <li>Our script never does this – but if you manually changed something, double‑check your <code>clinic.env</code>.</li>
</ul>

<hr>

<h2>⚠️ Disclaimer</h2>
<p>This project uses low‑level PipeWire audio links. While <code>pw-loopback</code> is much more resilient than <code>pw-link</code>, audio routing can still break after:</p>
<ul>
    <li>Operating system upgrades</li>
    <li>PipeWire or WirePlumber updates</li>
    <li>Major Zoom or Chrome updates</li>
</ul>
<p><strong>Use at your own risk.</strong><br>
Test thoroughly in a non‑clinical environment first.</p>
<p>Not affiliated with or endorsed by Zoom, Google/Chrome, OpenEvidence, or any other brand mentioned.</p>
<p><strong>Remember:</strong> Ensure your version of Zoom is HIPAA compliant / has a BAA for clinical use.</p>

<hr>

<div class="footer-note">
    <p style="margin:0; color:#555; font-size:0.9rem;">
        Made for Ubuntu 26.04 · Questions or issues? Open an issue on GitHub.
    </p>
</div>

</body>
</html>
