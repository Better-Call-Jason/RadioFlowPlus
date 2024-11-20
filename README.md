# RadioFlow+ : Push-Button Broadcasting

Transform your MP3 collection into your own streaming station in minutes. With RadioFlow+, if you can copy files to a folder, you can run your own music station. Drop in your mixtapes, podcasts, or music collection, and instantly start broadcasting to listeners worldwide. It's like having your own Spotify or Pandora, but it's all yours - simple, streamlined, and completely under your control.


## Prerequisites

For Ubuntu 22.04 users:
```bash
# Install Docker and Docker Compose from Ubuntu repository
sudo apt update
sudo apt install docker.io docker-compose
```

The Ubuntu 22.04 repository provides:
- Docker Engine 20.10.12
- Docker Compose 1.29.2
- These versions are fully compatible with this project

Other requirements:
- Git (`sudo apt install git`)
- At least one MP3 file to stream
- The repo has 3 sample mp3's

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


1. **Stream not accessible**
   - Verify Docker container is running: `docker ps`
   - Check container logs: `docker-compose logs`
   - Ensure port 8000 isn't being used by another application
   - Check if UFW is blocking the port: `sudo ufw status`

2. **No audio playing**
   - Confirm MP3 files are present in the recordings directory
   - Check file permissions (should be readable)
   - Verify MP3 file format compatibility

3. **Container won't start**
   ```bash
   # Check detailed logs
   docker-compose logs --tail=100
   
   # Restart the container
   docker-compose restart
   
   # If container fails to build
   docker-compose build --no-cache
   ```

4. **Permission Issues**
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

## Security Notes

- Change default passwords in `config/icecast.xml` before deploying to production
- Consider using a reverse proxy (like Nginx) for SSL termination
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

RadioFlow+ is open source software licensed under the MIT License. You can freely use, modify, and distribute this software. However, it comes with ABSOLUTELY NO WARRANTY. See the LICENSE file for details.


## Parting Shot 

As James Evan Pilato says, Don't Hate The Media Become The Media
