#!/bin/bash
set -e

# Initialize OPAM environment
source /etc/profile
eval $(opam env)

# Get the host IP address (can be accessed from inside container)
HOST_IP=$(hostname -i)

echo "Starting Icecast2 service..."
service icecast2 start
echo "✓ Icecast2 service started successfully"

# Make sure icecast is actually running
if ! pgrep icecast2 > /dev/null; then
    echo "❌ ERROR: Icecast2 failed to start"
    exit 1
fi

echo "Waiting for Icecast2 to be fully initialized..."
sleep 5

echo -e "\n🎵 Stream is now ONLINE"
echo -e "📻 Stream URL: \033[4;94mhttp://localhost:8000/stream\033[0m"
echo -e "✨ Playlist successfully built\n"

echo "Starting Liquidsoap..."
liquidsoap /config/liquidsoap.liq
