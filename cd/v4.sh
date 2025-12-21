#!/bin/bash

# Benar ASCII Art Banner
cat << "EOF"
   ______                   _ _______        _                  
  |___  /                  (_)__   __|      | |                 
     / / ___ _ __  ___  ___ _   | | ___  ___| |__              
    / / / _ \ '_ \/ __|/ _ \ |  | |/ _ \/ __| '_ \             
   / /_|  __/ | | \__ \  __/ |  | |  __/ (__| | | |             
  /_____\___|_| |_|___/\___|_|  |_|\___|\___|_| |_| 
EOF

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Start Tailscale service

# Attempt auto-connect using placeholder key
sudo tailscale up 

echo "Tailscale setup attempted. Login."
