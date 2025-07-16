# Xcel Itron Smart Meter to MQTT - Usage Guide

This guide provides practical examples and commands for using all the available options in the Xcel Itron smart meter to MQTT bridge.

## Table of Contents
- [Environment Variables](#environment-variables)
- [Docker Compose Options](#docker-compose-options)
- [Command Line Options](#command-line-options)
- [Certificate Management](#certificate-management)
- [Troubleshooting Commands](#troubleshooting-commands)
- [Monitoring and Debugging](#monitoring-and-debugging)

## Environment Variables

### MQTT Configuration

| Variable | Example Value | Description | Command Example |
|----------|---------------|-------------|-----------------|
| `MQTT_SERVER` | `192.168.1.100` | MQTT broker IP address | `docker run -e MQTT_SERVER=192.168.1.100 ...` |
| `MQTT_PORT` | `8883` | MQTT broker port (SSL) | `docker run -e MQTT_PORT=8883 ...` |
| `MQTT_TOPIC_PREFIX` | `sensors/` | Custom topic prefix | `docker run -e MQTT_TOPIC_PREFIX=sensors/ ...` |
| `MQTT_USER` | `myuser` | MQTT username | `docker run -e MQTT_USER=myuser ...` |
| `MQTT_PASSWORD` | `mypass123` | MQTT password | `docker run -e MQTT_PASSWORD=mypass123 ...` |

### Meter Configuration

| Variable | Example Value | Description | Command Example |
|----------|---------------|-------------|-----------------|
| `METER_IP` | `192.168.1.50` | Smart meter IP address | `docker run -e METER_IP=192.168.1.50 ...` |
| `METER_PORT` | `8081` | Smart meter port | `docker run -e METER_PORT=8081 ...` |

### Certificate Configuration

| Variable | Example Value | Description | Command Example |
|----------|---------------|-------------|-----------------|
| `CERT_PATH` | `/certs/meter.crt` | Custom certificate path | `docker run -e CERT_PATH=/certs/meter.crt ...` |
| `KEY_PATH` | `/certs/meter.key` | Custom private key path | `docker run -e KEY_PATH=/certs/meter.key ...` |

### Logging Configuration

| Variable | Example Value | Description | Command Example |
|----------|---------------|-------------|-----------------|
| `LOGLEVEL` | `DEBUG` | Logging level (DEBUG, INFO, WARNING, ERROR) | `docker run -e LOGLEVEL=DEBUG ...` |

## Docker Compose Options

### Basic Setup

```yaml
# docker-compose.yaml
version: "3.8"
services:
  xcel_itron2mqtt:
    image: ghcr.io/zaknye/xcel_itron2mqtt:main
    environment:
      MQTT_SERVER: mqtt
      METER_IP: 192.168.1.50
      LOGLEVEL: INFO
    volumes:
      - ./certs:/opt/xcel_itron2mqtt/certs:ro
```

### Advanced Setup with Custom MQTT Broker

```yaml
# docker-compose.yaml
version: "3.8"
services:
  xcel_itron2mqtt:
    image: ghcr.io/zaknye/xcel_itron2mqtt:main
    environment:
      MQTT_SERVER: external-mqtt.example.com
      MQTT_PORT: 8883
      MQTT_USER: myuser
      MQTT_PASSWORD: mypass123
      MQTT_TOPIC_PREFIX: home/energy/
      METER_IP: 192.168.1.50
      METER_PORT: 8081
      CERT_PATH: /opt/xcel_itron2mqtt/certs/.cert.pem
      KEY_PATH: /opt/xcel_itron2mqtt/certs/.key.pem
      LOGLEVEL: DEBUG
    volumes:
      - ./certs:/opt/xcel_itron2mqtt/certs:ro
    network_mode: host
    restart: unless-stopped
```

### Multi-Network Setup (VLAN)

```yaml
# docker-compose.yaml
version: "3.8"
services:
  xcel_itron2mqtt:
    image: ghcr.io/zaknye/xcel_itron2mqtt:main
    environment:
      MQTT_SERVER: 192.168.1.100
      METER_IP: 10.0.0.50  # Meter on different VLAN
      METER_PORT: 8081
      LOGLEVEL: INFO
    volumes:
      - ./certs:/opt/xcel_itron2mqtt/certs:ro
    network_mode: host
    restart: unless-stopped
```

## Command Line Options

### Basic Docker Run

```bash
# Basic setup with auto-discovery
docker run -d \
  --name xcel_meter \
  --network host \
  -v $(pwd)/certs:/opt/xcel_itron2mqtt/certs:ro \
  -e MQTT_SERVER=192.168.1.100 \
  ghcr.io/zaknye/xcel_itron2mqtt:main
```

### Advanced Docker Run with All Options

```bash
# Full configuration example
docker run -d \
  --name xcel_meter \
  --network host \
  -v $(pwd)/certs:/opt/xcel_itron2mqtt/certs:ro \
  -e MQTT_SERVER=192.168.1.100 \
  -e MQTT_PORT=1883 \
  -e MQTT_TOPIC_PREFIX=homeassistant/ \
  -e MQTT_USER=myuser \
  -e MQTT_PASSWORD=mypass123 \
  -e METER_IP=192.168.1.50 \
  -e METER_PORT=8081 \
  -e CERT_PATH=/opt/xcel_itron2mqtt/certs/.cert.pem \
  -e KEY_PATH=/opt/xcel_itron2mqtt/certs/.key.pem \
  -e LOGLEVEL=DEBUG \
  ghcr.io/zaknye/xcel_itron2mqtt:main
```

### Development Mode

```bash
# Interactive development container
docker run -it \
  --name xcel_dev \
  --network host \
  -v $(pwd):/opt/xcel_itron2mqtt \
  --entrypoint /bin/bash \
  ghcr.io/zaknye/xcel_itron2mqtt:main
```

## Certificate Management

### Generate New Certificates

```bash
# Generate new certificates and get LFDI
./scripts/generate_keys.sh

# Output example:
# The following string of numbers should be used as your LFDI value on the Xcel website:
# 8FA6803F07F4AABB88B9543013B1A55306AE933C
```

### Retrieve Existing LFDI

```bash
# Print LFDI from existing certificates
./scripts/generate_keys.sh -p

# Output example:
# The following string of numbers should be used as your LFDI value on the Xcel website:
# 8FA6803F07F4AABB88B9543013B1A55306AE933C
```

### Custom Certificate Paths

```bash
# Use custom certificate locations
docker run -d \
  --name xcel_meter \
  --network host \
  -v /path/to/custom/certs:/opt/xcel_itron2mqtt/certs:ro \
  -e CERT_PATH=/opt/xcel_itron2mqtt/certs/custom.crt \
  -e KEY_PATH=/opt/xcel_itron2mqtt/certs/custom.key \
  -e MQTT_SERVER=192.168.1.100 \
  ghcr.io/zaknye/xcel_itron2mqtt:main
```

## Troubleshooting Commands

### Check Container Status

```bash
# Check if container is running
docker ps | grep xcel

# Check container logs
docker logs xcel_itron2mqtt

# Follow logs in real-time
docker logs -f xcel_itron2mqtt
```

### Test MQTT Connectivity

```bash
# Test MQTT connection from host
mosquitto_sub -h 192.168.1.100 -p 1883 -t "homeassistant/#" -v

# Test MQTT connection from container
docker exec -it xcel_itron2mqtt mosquitto_sub -h mqtt -p 1883 -t "homeassistant/#" -v
```

### Debug Network Connectivity

```bash
# Test meter connectivity from host
curl -k https://192.168.1.50:8081/sdev/sdi

# Test meter connectivity from container
docker exec -it xcel_itron2mqtt curl -k https://192.168.1.50:8081/sdev/sdi

# Check mDNS discovery
docker exec -it xcel_itron2mqtt python3 -c "
from zeroconf import Zeroconf, ServiceBrowser, ServiceListener
import time

class MeterListener(ServiceListener):
    def add_service(self, zc, type, name):
        info = zc.get_service_info(type, name)
        print(f'Found meter: {info.parsed_addresses()[0]}:{info.port}')

zeroconf = Zeroconf()
listener = MeterListener()
browser = ServiceBrowser(zeroconf, '_smartenergy._tcp.local.', listener)
time.sleep(10)
zeroconf.close()
"
```

### Validate Certificate Files

```bash
# Check certificate file permissions
ls -la certs/

# Verify certificate content
openssl x509 -in certs/.cert.pem -text -noout

# Check private key
openssl rsa -in certs/.key.pem -check

# Verify LFDI matches certificate
openssl x509 -noout -fingerprint -SHA256 -inform pem -in certs/.cert.pem | \
  sed -e 's/://g' -e 's/SHA256 Fingerprint=//g' | cut -c1-40
```

## Monitoring and Debugging

### Real-time Monitoring

```bash
# Monitor all MQTT topics
./monitor_mqtt.sh

# Monitor specific topic
docker exec -it mosquitto mosquitto_sub -t "homeassistant/sensor/xcel_meter/instantaneous_demand" -v

# Monitor with timestamp
docker exec -it mosquitto mosquitto_sub -t "homeassistant/#" -v | while read line; do
  echo "$(date): $line"
done
```

### Performance Monitoring

```bash
# Check container resource usage
docker stats xcel_itron2mqtt

# Monitor network connections
docker exec -it xcel_itron2mqtt netstat -tulpn

# Check Python process
docker exec -it xcel_itron2mqtt ps aux | grep python
```

### Log Analysis

```bash
# Search for errors in logs
docker logs xcel_itron2mqtt 2>&1 | grep -i error

# Search for connection issues
docker logs xcel_itron2mqtt 2>&1 | grep -i "connection\|timeout"

# Search for MQTT messages
docker logs xcel_itron2mqtt 2>&1 | grep -i "mqtt"

# Get last 100 lines with timestamps
docker logs --tail=100 -t xcel_itron2mqtt
```

## Advanced Usage Examples

### Multiple Meters Setup

```yaml
# docker-compose.yaml
version: "3.8"
services:
  xcel_meter_1:
    image: ghcr.io/zaknye/xcel_itron2mqtt:main
    environment:
      MQTT_SERVER: mqtt
      METER_IP: 192.168.1.50
      MQTT_TOPIC_PREFIX: homeassistant/meter1/
      LOGLEVEL: INFO
    volumes:
      - ./certs:/opt/xcel_itron2mqtt/certs:ro
    network_mode: host
    restart: unless-stopped

  xcel_meter_2:
    image: ghcr.io/zaknye/xcel_itron2mqtt:main
    environment:
      MQTT_SERVER: mqtt
      METER_IP: 192.168.1.51
      MQTT_TOPIC_PREFIX: homeassistant/meter2/
      LOGLEVEL: INFO
    volumes:
      - ./certs:/opt/xcel_itron2mqtt/certs:ro
    network_mode: host
    restart: unless-stopped
```

### SSL MQTT Broker

```yaml
# docker-compose.yaml
version: "3.8"
services:
  xcel_itron2mqtt:
    image: ghcr.io/zaknye/xcel_itron2mqtt:main
    environment:
      MQTT_SERVER: ssl-mqtt.example.com
      MQTT_PORT: 8883
      MQTT_USER: myuser
      MQTT_PASSWORD: mypass123
      METER_IP: 192.168.1.50
      LOGLEVEL: INFO
    volumes:
      - ./certs:/opt/xcel_itron2mqtt/certs:ro
    network_mode: host
    restart: unless-stopped
```

### Custom Polling Rate

```bash
# Modify the polling rate in the source code
docker run -d \
  --name xcel_meter \
  --network host \
  -v $(pwd):/opt/xcel_itron2mqtt \
  -e MQTT_SERVER=192.168.1.100 \
  -e METER_IP=192.168.1.50 \
  --entrypoint /bin/bash \
  ghcr.io/zaknye/xcel_itron2mqtt:main \
  -c "sed -i 's/POLLING_RATE = 5.0/POLLING_RATE = 10.0/' /opt/xcel_itron2mqtt/xcelMeter.py && python3 -Wignore /opt/xcel_itron2mqtt/main.py"
```

## Environment Variable Reference

### Complete .env Example

```bash
# MQTT Configuration
MQTT_SERVER=mqtt
MQTT_PORT=1883
MQTT_TOPIC_PREFIX=homeassistant/
MQTT_USER=
MQTT_PASSWORD=

# Meter Configuration
METER_IP=192.168.1.50
METER_PORT=8081

# Certificate Configuration
CERT_PATH=/opt/xcel_itron2mqtt/certs/.cert.pem
KEY_PATH=/opt/xcel_itron2mqtt/certs/.key.pem

# Logging
LOGLEVEL=INFO
```

### Validation Commands

```bash
# Validate environment variables
docker run --rm \
  -e MQTT_SERVER=test \
  -e METER_IP=192.168.1.50 \
  -e LOGLEVEL=DEBUG \
  ghcr.io/zaknye/xcel_itron2mqtt:main \
  python3 -c "import os; print('MQTT_SERVER:', os.getenv('MQTT_SERVER')); print('METER_IP:', os.getenv('METER_IP')); print('LOGLEVEL:', os.getenv('LOGLEVEL'))"
```

This comprehensive guide provides practical examples for every option and configuration scenario you might encounter when using the Xcel Itron smart meter to MQTT bridge. 