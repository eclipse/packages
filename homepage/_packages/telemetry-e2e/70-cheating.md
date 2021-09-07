---
title: 'Cheating'
layout: package-page
twitterTitle: Telemetry end-to-end | Cheating
description: How to cheat.
---

{% capture main %}

The tutorial involves a lot of components, and a lot can go wrong, especially when it comes to bluetooth or network
connectivity.

If you run into any blockers, we would kindly ask you to [reach out to us](https://github.com/eclipse/packages/issues/new)
and report your findings.

But, there is also a way to simulate the actual hardware and work around some requirements.

## Simulating a message

You can manually simulate a message, that the IoT gateway would normally send after it acquired the information
from the sensor.

{% variants %}

{% variant URL %}

Ensure that the `DOMAIN` variable is still set to the value you used for the installation. Then execute the following
command:

{% clipboard %}
http --auth device-1@eclipse:foobar POST http://http-endpoint$DOMAIN/v1/foo temp:=23
{% endclipboard %}
{% endvariant %}

{% variant drg %}
<p>If you are logged in with `drg`:</p>
{% clipboard %}
http --auth device-1@eclipse:foobar POST $(drg whoami -e http)/v1/foo temp:=23
{% endclipboard %}
{% endvariant %}

{% endvariants %}


{% alert info: Different protocol %}
You might have notices, we used HTTP for this. However, Kura would send the message using MQTT. As one part of
Drogue IoT is normalizing the IoT protocol, the backend system didn't even notice.
{% endalert %}

## Reading directly from the digital twin

When data gets sent to Ditto, it gets forwarded to Streamsheets for visualization. Should the data not show up in
streamsheets, or should you run into issues with Streamsheets, you can also directly query the data in Ditto.

Ensure that the `DOMAIN` variable is still set to the value you used for the installation. Then execute the following
command:

{% clipboard %}
curl -sL -X GET "http://ditto-default$DOMAIN/api/2/things/eclipse:device-1" -H  "accept: application/json" -H  "Authorization: Basic ZGl0dG86ZGl0dG8=" | jq
{% endclipboard %}

{% endcapture %}

{% capture aside %}
{% include toc.html sticky=true %}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
