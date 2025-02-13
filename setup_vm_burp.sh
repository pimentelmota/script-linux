#!/bin/bash

# Start timer
start_time=$(date +%s)

DEFAULT_BURP_VERSION="2024.12.1"  # Default version if fetching fails

# Use curl to fetch the webpage and grep to find the version number
BURP_VERSION_RAW=$(curl -s "https://portswigger.net/burp/releases" | grep -oP 'Professional / Community \K\d+\.\d+\.\d+' | head -n 1)

# Check if version extraction was successful
if [ -z "${BURP_VERSION_RAW}" ]; then
  echo "Warning: Could not automatically determine the latest Burp Suite version."
  echo "Falling back to default Burp Suite version: ${DEFAULT_BURP_VERSION}"
  BURP_VERSION="${DEFAULT_BURP_VERSION}" # Use default version
else
  BURP_VERSION="${BURP_VERSION_RAW}"
  echo "Latest Burp Suite Community Edition version found: ${BURP_VERSION}"
fi
# -----------------------------------------------------

# Update package lists to ensure you have the latest versions
sudo apt update

# Install minimal Xorg server...
echo "Installing minimal Xorg server..."
sudo apt install -y xorg

# Install Openbox window manager...
echo "Installing Openbox window manager..."
sudo apt install -y openbox

# Install LXTerminal terminal emulator...
echo "Installing LXTerminal terminal emulator..."
sudo apt install -y lxterminal

# Install Network Manager GUI...
echo "Installing Network Manager GUI..."
sudo apt install -y network-manager-gnome

# Install jgmenu for application menu...
echo "Installing jgmenu for application menu..."
sudo apt install -y jgmenu

# Install PCManFM file manager...
echo "Installing PCManFM file manager..."
sudo apt install -y pcmanfm

# (Optional) Install policykit-1-gnome - might be needed for GUI authentication
echo "Installing PolicyKit GUI agent (optional)..."
sudo apt install -y policykit-1-gnome

# Install Chrome Remote Desktop...
echo "Installing Chrome Remote Desktop..."
curl -o /tmp/chrome-remote-desktop_current_amd64.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
sudo apt install -y /tmp/chrome-remote-desktop_current_amd64.deb

# Install Google Chrome Stable...
echo "Installing Google Chrome Stable..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
sudo apt install -y ./google-chrome-stable_current_amd64.deb

# Install Burp Suite Community Edition
echo "Installing Burp Suite Community Edition (Version: ${BURP_VERSION})..."
sudo wget "https://portswigger.net/burp/releases/startdownload?product=community&version=${BURP_VERSION}&type=Linux" -O burpsuite && \
sudo chmod 777 burpsuite && \
sudo ./burpsuite -q #  <- Removed -q for possible background operation and will start explicitly below

# Start Burp Suite in the background
echo "Starting Burp Suite in the background..."
nohup ./burpsuite --no-ui &  # Start Burp Suite without GUI in background
sleep 10 # Wait for Burp Suite to start and initialize web server for CA cert

# Determine Downloads directory
DOWNLOADS_DIR="$HOME/Downloads"
if [ ! -d "${DOWNLOADS_DIR}" ]; then
  echo "Warning: Downloads directory not found at ${DOWNLOADS_DIR}. Falling back to home directory."
  DOWNLOADS_DIR="$HOME" # Fallback to home directory if Downloads doesn't exist
fi

# Download Burp Suite CA Certificate to Downloads folder
CERT_FILE="${DOWNLOADS_DIR}/burpsuite_ca.crt" # Define where to save the certificate in Downloads
echo "Downloading Burp Suite CA Certificate to ${CERT_FILE}..."
curl http://burpsuite/cert -o "${CERT_FILE}"

echo "Burp Suite CA Certificate downloaded and saved to: ${CERT_FILE}"
echo "Please import this certificate from your Downloads folder into your browser(s) to intercept HTTPS traffic."
echo "Instructions can be found at: https://portswigger.net/burp/documentation/desktop/ca-certificate/index.net"

# End timer and calculate duration
end_time=$(date +%s)
duration_seconds=$((end_time - start_time))

# Calculate hours, minutes, and seconds
duration_hours=$((duration_seconds / 3600))
duration_minutes=$(( (duration_seconds % 3600) / 60 ))
duration_secs=$((duration_seconds % 60))

# Format the duration output
if [ $duration_hours -gt 0 ]; then
  duration_output="${duration_hours} hours, ${duration_minutes} minutes, ${duration_secs} seconds"
elif [ $duration_minutes -gt 0 ]; then
  duration_output="${duration_minutes} minutes, ${duration_secs} seconds"
else
  duration_output="${duration_secs} seconds"
fi

echo "All commands executed. Please check for any errors above."
echo "Installation process completed in ${duration_output}."
