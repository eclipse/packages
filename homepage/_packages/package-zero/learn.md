---
title: 'Learn more'
layout: package-page
---

{%- capture main -%}
## Functionality

This package gives you a scalable, cloud based IoT messaging platform. This allows you the equip
your sensor like devices to report telemetry data to a central location and receive back commands
from the cloud backend.

The IoT messaging layer takes care of normalizing the various IoT protocol on AMQP 1.0, so that
the backend applications can focus on processing the messages, rather than implementing various
protocols. The messaging layer also provides the authentication and authorization layer. Ensuring
that the backend applications only receive information from properly authenticated and authorized
devices.

For making the implementation of backend applications easier, the digital twin platform will
pre-process the incoming message stream, and translate it into a last-known state of the various
devices. This makes it easier to implement backend applications, as the state is being managed
by the digital twin platform.

In addition to the actual processing of data, the package also provides a feature to update the
firmware of the devices, planning and orchestrating rollouts of new versions.

## Example use-case

…

{%- endcapture -%}

{%- capture aside -%}

## Also see

* About Eclipse Hono
    * [Getting started](https://www.eclipse.org/hono/getting-started/)
    * [Documentation](https://www.eclipse.org/hono/docs/)
* About Eclipse Ditto
    * [Overview](https://www.eclipse.org/ditto/intro-overview.html)
* About Eclipse Hawkbit
    * [Getting started](https://www.eclipse.org/hawkbit/gettingstarted/)

{%- endcapture -%}

{%- include side-page.html main=main aside=aside -%}