# Dockerfile
FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Pre-configure icecast2 to skip interactive configuration
RUN echo "icecast2 icecast2/icecast-setup boolean false" | debconf-set-selections

# Install required packages
RUN apt-get update && apt-get install -y \
    icecast2 \
    liquidsoap=2.0.2-1build2 \
    mime-support \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /recordings /config /var/log/icecast2

# Set up liquidsoap user properly
RUN usermod -s /bin/bash liquidsoap && \
    mkdir -p /home/liquidsoap && \
    chown liquidsoap:liquidsoap /home/liquidsoap

# Copy configuration files
COPY config/icecast.xml /etc/icecast2/icecast.xml
COPY config/liquidsoap.liq /config/liquidsoap.liq
COPY scripts/start.sh /start.sh

# Set permissions
RUN chown -R icecast2:icecast /etc/icecast2 \
    && chown -R icecast2:icecast /var/log/icecast2 \
    && chown -R liquidsoap:liquidsoap /recordings \
    && chown -R liquidsoap:liquidsoap /config \
    && chmod +x /start.sh

# Expose Icecast port
EXPOSE 8000

# Start services
CMD ["/start.sh"]
