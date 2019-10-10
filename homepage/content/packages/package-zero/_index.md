---
title: 'Package Zero'
date: 2019-09-24T14:51:12+2:00
images:
- /images/project-zero.jpg
projects:
- iot.hono
- iot.ditto
- iot.hawkbit
description: A package connecting and managing sensor style devices. Connecting sensors to the cloud, processing data with a digital twin platform, and managing device firmware.
---

## Overview

In order to have a better understanding, the following diagram will give you a brief overview of the package.

{{<row>}}

{{<col "sm-6">}}

{{<img-fluid src="images/overview.png" title="Overview diagram">}}

{{</col>}}

{{<col "sm-6">}}

<p class="border-callout-left" style="border-color: #ff972f;">
<strong>Eclipse Hono</strong> provides the IoT messaging layer. It allows the devices to connect into the cluster
using various IoT specific protocols (e.g. MQTT). Connections will be authenticated based on data from
the <em>device registry</em>. Messages will be passed through the <em>router</em>, for volatile messages, and through
the <em>broker</em> for persistent messages.
</p>

<p class="border-callout-left" style="border-color: #81aca6;">
<strong>Eclipse Ditto</strong> will tap into the stream of messages, coming from Hono and the devices. It will
pre-process it, so that applications can work with more structured data.
</p>

<p class="border-callout-left" style="border-color: #8e86ae;">
<strong>Eclipse Hawkbit</strong> will take care of rolling out new messages. For this it will also use the messaging
layer provided by Hono.
</p>

<p class="border-callout-left" style="border-color: #729fcf;">
This enables your <strong>Custom Application</strong> to easily communicate with the devices, using a
structured data model, a scalable messaging layer.
</p>

{{</col>}}

{{</row>}}
