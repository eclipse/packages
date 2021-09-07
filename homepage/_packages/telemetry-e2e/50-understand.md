---
title: 'Understanding it'
layout: package-page
twitterTitle: Telemetry end-to-end | Understanding it
description: Understanding what is happening.
---

{% capture main %}

This example involved a few components. "Just" to get a temperature reading. Can't this be done in a simpler way?

Yes. However, please don't forget that this is a showcase of Eclipse IoT technologies. So we are not aiming for a
minimalistic architecture. But beside that, still every component in this architecture fulfills an important
functionality. Read on, to learn what the different components do to get a better understand why they are needed. 

## The sensor

<p class="lead">
The Drogue Device based firmware acquires the actual value and makes it available using a low power wireless protocol.
</p>

The firmware in the sensor periodically takes a reading of the internal temperature sensor. That value may not be
very accurate, as the board heats up when it is powered, but it still makes a nice value to play with as it only
changes slowly, but you still can influence it.

Also does the firmware announce itself using Bluetooth. And once someone connects, it provides the temperature
information using the GATT profile.

## The IoT gateway

<p class="lead">
Eclipse Kura acts as the IoT gateway, bridging the local Bluetooth network with the global TCP/IP based IoT network.
</p>

Part of this general purpose IoT gateway is a small application, which makes use of the Bluetooth services, provided
by the gateway's software framework, to scan for devices and read their data.

Once it finds the micro:bit, it will connect and start reading out the temperature information automatically. 
The data which is read is then handed over to the cloud connector, which is also provided by the gateway's
software stack. 

The connector is connected to cloud side MQTT endpoint. When the bluetooth application inside the gateway
provides an update, the cloud service delivers that to the MQTT cloud endpoint. That service will also perform a
re-connect when necessary, and buffer data should the connection be disrupted.

## IoT ingress

<p class="lead">
Drogue Cloud provides the IoT specific endpoints, normalizing the protocol layer in the process.
</p>

Drogue cloud provides the MQTT endpoint, which accepts the connection coming in from the Kura cloud connector. It
authenticates the device and then waits for it to publish messages.

When a message is received, it will wrap its payload into a Cloud Event structure, and forward it to the Apache Kafka
topic of the application.

## Digital twin

<p class="lead">
Eclipse Ditto implements the digital twin, and normalizes the data structure coming in from Drogue Cloud.
</p>

It is connected to the application specific Kafka topic on the Drogue Cloud side. When a new event is
received from Kafka, a small JavaScript code snippet decodes the Cloud Events message, extracts the temperature information,
and translates it into a Ditto protocol message. That code is run as part of the Ditto instance.

If the message is valid, Ditto will update the internal state of the twin, and send out any change event that was
created in the process.

One change lister that is registered, is the connection to Streamsheets. When a change of the twin state occurs,
this change is sent to the Streamsheets internal MQTT broker, which is used to distribute data inside Streamsheets.

## Visualization

<p class="lead">
Eclipse Streamsheets is used to visualize the current state of the device.
</p>

Streamsheets receives the change events using its internal MQTT broker, updates its internal spreadsheet state, and refreshes
all open browser sessions to reflect the update.

{% endcapture %}

{% capture aside %}
{% include toc.html sticky=true %}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
