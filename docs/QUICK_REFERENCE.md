# Quick Reference - Xcel Itron Smart Meter to MQTT

## 🚀 Quick Start Commands

```bash
# 1. Setup (generate certs and create .env)
./setup.sh

# 2. Edit .env to add your meter IP
nano .env

# 3. Start services
docker-compose up -d

# 4. Monitor MQTT data
./monitor_mqtt.sh
```

## 📋 Environment Variables Quick Reference

| Variable | Required | Default | Example |
|----------|----------|---------|---------|
| `MQTT_SERVER` | ✅ | - | `192.168.1.100` |
| `METER_IP` | ✅ | - | `192.168.1.50` |
| `MQTT_PORT` | ❌ | `1883` | `8883` |
| `MQTT_TOPIC_PREFIX` | ❌ | `homeassistant/` | `sensors/` |
| `METER_PORT` | ❌ | `8081` | `8081` |
| `LOGLEVEL` | ❌ | `INFO` | `DEBUG` |

## 🔧 Common Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f xcel_itron2mqtt

# Check status
docker-compose ps

# Restart service
docker-compose restart xcel_itron2mqtt
```

## 📊 Monitoring Commands

```bash
# Monitor all MQTT topics
./monitor_mqtt.sh

# Monitor specific topic
docker exec mosquitto mosquitto_sub -t "homeassistant/sensor/xcel_meter/instantaneous_demand" -v

# Check container logs
docker-compose logs --tail=50 xcel_itron2mqtt

# Test setup
./test_setup.sh
```

## 🔍 Troubleshooting Commands

```bash
# Check if container is running
docker ps | grep xcel

# Check certificate files
ls -la certs/

# Test meter connectivity
curl -k https://YOUR_METER_IP:8081/sdev/sdi

# Get LFDI from existing certs
./scripts/generate_keys.sh -p
```

## 📝 Common .env Configurations

### Basic Setup
```bash
MQTT_SERVER=mqtt
METER_IP=192.168.1.50
LOGLEVEL=INFO
```

### Advanced Setup
```bash
MQTT_SERVER=192.168.1.100
MQTT_PORT=1883
MQTT_TOPIC_PREFIX=homeassistant/
MQTT_USER=myuser
MQTT_PASSWORD=mypass123
METER_IP=192.168.1.50
METER_PORT=8081
CERT_PATH=/opt/xcel_itron2mqtt/certs/.cert.pem
KEY_PATH=/opt/xcel_itron2mqtt/certs/.key.pem
LOGLEVEL=DEBUG
```

## 🐳 Docker Run Examples

### Basic
```bash
docker run -d \
  --name xcel_meter \
  --network host \
  -v $(pwd)/certs:/opt/xcel_itron2mqtt/certs:ro \
  -e MQTT_SERVER=192.168.1.100 \
  -e METER_IP=192.168.1.50 \
  ghcr.io/zaknye/xcel_itron2mqtt:main
```

### With All Options
```bash
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
  -e LOGLEVEL=DEBUG \
  ghcr.io/zaknye/xcel_itron2mqtt:main
```

## 📡 MQTT Topics

Common topics you'll see:
- `homeassistant/sensor/xcel_meter/instantaneous_demand`
- `homeassistant/sensor/xcel_meter/current_summation`
- `homeassistant/sensor/xcel_meter/frequency`
- `homeassistant/sensor/xcel_meter/voltage`

## 🔐 Certificate Management

```bash
# Generate new certificates
./scripts/generate_keys.sh

# Get LFDI from existing certs
./scripts/generate_keys.sh -p

# Check certificate validity
openssl x509 -in certs/.cert.pem -text -noout
```

## 🚨 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Meter not found" | Check METER_IP in .env, verify LFDI registration |
| "Connection refused" | Check meter IP accessibility, verify port 8081 |
| No MQTT messages | Check MQTT broker, verify container logs |
| Certificate errors | Regenerate certificates with `./scripts/generate_keys.sh` |

## 📞 Support Commands

```bash
# Get system info
docker info

# Check network connectivity
ping YOUR_METER_IP

# Validate docker-compose config
docker-compose config

# Check available images
docker images | grep xcel
```

## 🔄 Development Commands

```bash
# Run in development mode
docker-compose run --rm xcel_itron2mqtt /bin/bash

# Build custom image
docker build -t my-xcel-meter .

# Run with custom entrypoint
docker run -it --entrypoint /bin/bash ghcr.io/zaknye/xcel_itron2mqtt:main
``` 