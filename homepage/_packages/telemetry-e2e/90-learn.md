---
title: 'Learn more'
layout: package-page
twitterTitle: Telemetry end-to-end | Learn more
description: Learn more about the Telemetry end-to-end package.
---

{%- capture main -%}

## Check the source

As all of this is open source, you can not only check [the code of this package](https://github.com/eclipse/packages/tree/master/packages/telemetry-e2e), you can also dive into the code of all backing projects.

A few noteworthy links specific to this package are:

* [The code to the micro:bit firmware](https://github.com/drogue-iot/drogue-device/tree/main/examples/nrf52/microbit/ble-temperature)
* [The code to the Eclipse Kura addon](https://github.com/ctron/kura-addons/tree/master/examples/de.dentrassi.kura.addons.example.microbit)
* [The snippet of the Ditto payload mapper](https://github.com/eclipse/packages/blob/master/packages/telemetry-e2e/extra/drogue-cloud-incoming.js)
* [The Streamsheets Kubernetes deployment](https://github.com/ctron/streamsheets-kubernetes)

## Reach out

All projects participating in this package have their own communities and communication channels. Take a look, and 
maybe reach out to learn more or give some feedback:

* [Eclipse IoT Working Group](https://iot.eclipse.org) – [Slack channel](https://eclipse-iot-wg.slack.com)
* Projects
  * [Eclipse Ditto](https://www.eclipse.org/ditto) – [Gitter channel](https://gitter.im/eclipse/ditto)
  * [Eclipse Kura](https://www.eclipse.org/kura) – [Discussion forum](https://www.eclipse.org/kura/community.php#discussion-forum)
  * [Eclipse Streamsheets](https://www.eclipse.org/streamsheets) – [Mailing list](https://accounts.eclipse.org/mailing-list/streamsheets-dev)
  * [Drogue IoT](https://drogue.io) – [Matrix channel](https://matrix.to/#/#drogue-iot:matrix.org)

## What is next?

Here are a few ideas of what you could do next.

### Add a new sensor value

If you want to make an end-to-end change, add another value from one of the micro:bit's sensor to the data. This would
include:

* Adding the readout to the firmware
* Reading it as part of the Kura addon example
* Extracting it in the Ditto mapper, assigning it a new device feature
* Mapping the field to a new cell in streamsheets.

### Play with the visualization

Instead of just showing a plain value, you could play with the spreadsheet. Maybe start by showing Fahrenheit instead
of Celsius? Or Kelvin? You can also show the last few values in a table.

Check out the Streamsheets project to learn more.


{%- endcapture -%}

{%- capture aside -%}

## Projects

  * [Eclipse Ditto](https://www.eclipse.org/ditto)
  * [Eclipse Kura](https://www.eclipse.org/kura)
  * [Eclipse Streamsheets](https://www.eclipse.org/streamsheets)
  * [Drogue IoT](https://drogue.io)

{%- endcapture -%}

{%- include side-page.html main=main aside=aside -%}
