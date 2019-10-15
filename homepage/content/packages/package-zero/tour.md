---
title: 'Take a tour'
date: 2019-09-24T14:51:12+2:00
---

{{<row>}}

{{<col "12,md-8,lg-9">}}

    DEVICE_REGISTRY=https://foo-bar
    MQTT_ADAPTER_IP=mqtt-adapter

## Working with devices

### Create a new tenant
### Create a new device

* Register device
* Set device credentials

## Working with data

### Publish telemetry data via MQTT

Publish a telemetry message using the MQTT endpoint:

{{<clipboard>}}
    mosquitto_pub -h $MQTT_ADAPTER_IP \
      -u $MY_DEVICE@$MY_TENANT -P $MY_PWD \
      -t telemetry -m '{"temp": 5}'
{{</clipboard>}}

## Updating the firmware

{{</col>}}

{{<col "12,md-4,lg-3" "d-none d-md-block">}}
{{<toc sticky="true">}}
{{</col>}}

{{</row>}}