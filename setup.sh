#!/bin/bash

echo "Setting up Xcel Itron Smart Meter to MQTT Bridge"
echo "================================================"

# Check if certs directory exists
if [ ! -d "certs" ]; then
    echo "Creating certs directory..."
    mkdir -p certs
fi

# Check if certificates exist
if [ ! -f "certs/.cert.pem" ] || [ ! -f "certs/.key.pem" ]; then
    echo "Generating SSL certificates and keys..."
    ./scripts/generate_keys.sh
    echo ""
    echo "IMPORTANT: Copy the LFDI string above and add it to your Xcel Energy Launchpad"
    echo "Visit: https://my.xcelenergy.com/MyAccount/s/meters-and-devices/"
    echo "Click 'Add a Device' and paste the LFDI string"
    echo ""
else
    echo "Certificates already exist. To regenerate, run: ./scripts/generate_keys.sh"
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << EOF
# MQTT Configuration
MQTT_SERVER=mqtt
MQTT_PORT=1883
MQTT_TOPIC_PREFIX=homeassistant/
MQTT_USER=
MQTT_PASSWORD=

# Meter Configuration
METER_IP=
METER_PORT=8081

# Certificate Configuration
CERT_PATH=/opt/xcel_itron2mqtt/certs/.cert.pem
KEY_PATH=/opt/xcel_itron2mqtt/certs/.key.pem

# Logging
LOGLEVEL=INFO
EOF
    echo ".env file created. Please edit it to add your meter IP address."
else
    echo ".env file already exists."
fi

echo ""
echo "Setup complete! Next steps:"
echo "1. Edit .env file and add your METER_IP address"
echo "2. Run: docker-compose up -d"
echo "3. Check logs: docker-compose logs -f xcel_itron2mqtt"
echo "4. Monitor MQTT topics: docker-compose exec mosquitto mosquitto_sub -t 'homeassistant/#' -v" 