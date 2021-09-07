---
title: 'Device'
layout: package-page
twitterTitle: Telemetry end-to-end | Installation
description: Installations instructions for the Telemetry end-to-end package.
---

{% capture main %}

For running the sensor firmware, you will need a [micro:bit](https://microbit.org/) v2. Unfortunately, the example
does not work with earlier versions of the micro:bit. It also does not work with other boards, like e.g. the
Raspberry Pi Pico (which doesn't have Bluetooth), or the ESP32 (which has different CPU architecture: Xtensa or RISC-V).
As also the Bluetooth driver is part of the firmware, you cannot simply flash it to a different ARM based device.

However, as the overall example is only relying on Bluetooth, GATT, and the [micro:bit temperature profile](https://lancaster-university.github.io/microbit-docs/resources/bluetooth/bluetooth_profile.html). You can of
course drop in your down device, as long it is implementing the same profile.

One alternative to achieve the same, is to use "Make Code" with [this example project](https://makecode.microbit.org/_CcAYtycF5Tvy).

## Install Rust

In order to install Rust, [installing `rustup`](https://www.rust-lang.org/tools/install) is sufficient on most cases:

{% clipboard %}
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
{% endclipboard %}

## Clone the firmware repository

{% clipboard %}
git clone https://github.com/drogue-iot/drogue-device.git
{% endclipboard %}

## Flash the device

Attach the device to your USB port and execute the following command to build and flash the firmware:

{% clipboard %}
cd examples/nrf/microbit/ble-temperature
cargo run --release
{% endclipboard %}

Once the device is flashed, it will start to announce its services using Bluetooth.

## What is next?

{% alert success: Congratulations! %}
You set up the complete package! Now it is time to look at the data, take a look at the next page!
{% endalert %}

{% endcapture %}

{% capture aside %}
{% include toc.html sticky=true %}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
