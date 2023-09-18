---
title: 'Learn more'
layout: package-page
twitterTitle: Cloud2Edge | Learn more
description: Learn more about the Cloud2Edge package.
---

{%- capture main -%}
## Functionality

This package gives you a scalable, cloud based IoT messaging platform. This allows you to connect
sensors and devices to a cloud back end and let them report telemetry data and events to be consumed
by applications via the cloud back end.

The IoT messaging layer takes care of normalizing the various IoT protocols to AMQP 1.0, so that
the back end applications can focus on processing the messages, rather than implementing various
protocols. The messaging layer also provides the authentication and authorization layer. Ensuring
that the back end applications only receive information from properly authenticated and authorized
devices.

For making the implementation of back end applications easier, the digital twin platform will
pre-process the incoming message stream, and translate it into a last-known state of the various
devices. This makes it easier to implement back end applications, as the state is being managed
by the digital twin platform.

In addition to the actual processing of data, the package also provides a feature to plan, orchestrate
and monitor the roll-out of software updates to connected devices.

## Example use-case

…

{%- endcapture -%}

{%- capture aside -%}

## Also see

* About Eclipse Hono
    * [Getting started](https://www.eclipse.org/hono/docs/getting-started/)
    * [Documentation](https://www.eclipse.org/hono/docs/)
* About Eclipse Ditto
    * [Overview](https://www.eclipse.org/ditto/intro-overview.html)
* About Eclipse Hawkbit
    * [Getting started](https://www.eclipse.org/hawkbit/gettingstarted/)

{%- endcapture -%}

{%- include side-page.html main=main aside=aside -%}