#!/bin/bash

cd /insteonmqtt
source /insteonmqtt/bin/activate
/insteonmqtt/insteon-mqtt /etc/insteonmqtt/config.yaml start

