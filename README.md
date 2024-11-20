# Simple Continuous Broadcast Project

A Docker-based streaming server that continuously broadcasts MP3 files using Icecast2 and Liquidsoap.

## Design Philosophy
This project implements a minimalist, headless streaming approach:
- Deliberately excludes the Icecast admin panel and status pages
- Focuses solely on continuous audio streaming functionality
- Provides a lightweight, resource-efficient solution
- No GUI or web interface to manage - just pure streaming

## Prerequisites

For Ubuntu 22.04 users:
```bash
# Install Docker and Docker Compose from Ubuntu repository
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl enable --now docker

# Add your user to docker group (requires logout/login to take effect)
sudo usermod -aG docker $USER
```

The Ubuntu 22.04 repository provides:
- Docker Engine 20.10.12
- Docker Compose 1.29.2
- These versions are fully compatible with this project

Other requirements:
- Git (`sudo apt install git`)
- At least one MP3 file to stream

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/Better-Call-Jason/simple-broadcast-media-stream-icecast2.git
cd simple-continuous-broadcast-project
```

2. Replace the sample MP3 files in the `recordings` directory with your own:
```bash
# Remove sample files
rm recordings/*.mp3

# Copy your MP3 files
cp /path/to/your/mp3s/*.mp3 recordings/
```

3. Start the server:
```bash
docker-compose up -d    # Note: Ubuntu 22.04 uses docker-compose (with hyphen)
```

4. Access your stream at: `http://localhost:8000/stream`

## Project Structure

```
simple-continuous-broadcast-project/
├── config/
│   ├── icecast.xml        # Icecast2 configuration
│   └── liquidsoap.liq     # Liquidsoap streaming configuration
├── recordings/            # Directory for MP3 files
├── scripts/
│   └── start.sh          # Container startup script
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile           # Docker image definition
└── README.md           # This file
```

## Configuration

### Default Settings
- Stream URL: `http://localhost:8000/stream`
- Stream Format: MP3 (128kbps)
- Source Password: `source_password`
- Admin Password: `your_strong_admin_password_here`
- Playlist Mode: Normal (sequential playback)
- Playlist Behavior: Continuous replay indefinitely while container runs

### Playlist Configuration
The default configuration in `liquidsoap.liq` plays files sequentially:
```liquidsoap
recordings = playlist(
  reload=1,
  reload_mode="rounds",
  mode="normal",  # Files play in sequential order
  "/recordings"
)
```

To enable random playback, modify the mode parameter:
```liquidsoap
recordings = playlist(
  reload=1,
  reload_mode="rounds",
  mode="randomize",  # Files play in random order
  "/recordings"
)
```

Available playlist modes:
- `normal`: Plays files in sequential order
- `randomize`: Shuffles playback order
- `random`: Like randomize but can repeat a song before all others have played

The server will continuously stream and replay your audio files indefinitely as long as:
- The container is running
- There is at least one valid MP3 file in the recordings directory
- No errors occur in the streaming process

### Modifying Configuration
- To change Icecast settings, modify `config/icecast.xml`
- To adjust streaming parameters, modify `config/liquidsoap.liq`
- To update ports or volumes, modify `docker-compose.yml`

## Troubleshooting

### Common Issues

1. **Docker permissions issues**
   ```bash
   # If you get a permission denied error
   sudo chmod 666 /var/run/docker.sock
   
   # Or log out and back in after adding your user to docker group
   ```

2. **Stream not accessible**
   - Verify Docker container is running: `docker ps`
   - Check container logs: `docker-compose logs`
   - Ensure port 8000 isn't being used by another application
   - Check if UFW is blocking the port: `sudo ufw status`

3. **No audio playing**
   - Confirm MP3 files are present in the recordings directory
   - Check file permissions (should be readable)
   - Verify MP3 file format compatibility

4. **Container won't start**
   ```bash
   # Check detailed logs
   docker-compose logs --tail=100
   
   # Restart the container
   docker-compose restart
   
   # If container fails to build
   docker-compose build --no-cache
   ```

5. **Permission Issues**
   ```bash
   # Fix permissions on recordings directory
   chmod -R 644 recordings/*.mp3
   ```

### Logs
- Icecast logs are located in `/var/log/icecast2/` inside the container
- View logs using: `docker-compose logs -f`

## Advanced Usage

### Custom Stream Settings

To modify stream quality, edit `config/liquidsoap.liq`:
```liquidsoap
output.icecast(
  %mp3(bitrate=192), # Change bitrate here
  ...
)
```

### Multiple Streams

To add another mount point, add to `config/icecast.xml`:
```xml
<mount>
    <mount-name>/another_stream</mount-name>
    <username>source</username>
    <password>source_password</password>
</mount>
```

### System Service (Optional)
To run the stream as a system service on Ubuntu:

1. Create a service file:
```bash
sudo nano /etc/systemd/system/stream-server.service
```

2. Add the following content:
```ini
[Unit]
Description=Streaming Server
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/path/to/project
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

3. Enable and start the service:
```bash
sudo systemctl enable stream-server
sudo systemctl start stream-server
```

## Security Notes

- Change default passwords in `config/icecast.xml` before deploying to production
- Consider using a reverse proxy (like Nginx) for SSL termination
- Restrict access to admin interface if exposed publicly
- If using UFW firewall:
  ```bash
  sudo ufw allow 8000/tcp
  ```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
