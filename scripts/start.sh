#!/bin/bash

cd /insteon_mqtt
source /insteon_mqtt/bin/activate
exec /insteon_mqtt/bin/insteon-mqtt /etc/insteon_mqtt/config.yaml start

