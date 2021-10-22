---
title: 'Alternatives'
layout: package-page
twitterTitle: Telemetry end-to-end | Alternatives
description: Thinking about alternatives.
---

{% capture main %}

One thing to keep in mind is, that this is a demo to show an end-to-end integration of open source IoT with
Eclipse IoT projects. And it is intended to manage much more than a single device, with a single value. This is
a scalable cloud platform, which is targeted towards more complex use cases. To make it simpler for you, we are
focusing on a very basic use case. Which you can extend, if you like.

## Architecture

But let's take a look at some of the components and think about alternatives.

### The sensor

Bluetooth is used because it is a versatile, but still a low power wireless communication mechanism. You could easily
run this microcontroller on batteries for quite a while.

Using WiFi would increase the power consumption, but allow you to directly communication with the cloud.

LoRaWAN for example would allow for even more power savings, but reduce
the amount and frequency of the telemetry updates. For this example, it would also be challenging to self-host all
the LoRaWAN components.

### Digital twin

Do you really need a digital twin platform? Well, at some point your application needs to structure the data and
understand the structure. History has shown that structuring the data can be a problem, but in most cases isn't a big
one. Aligning on the same structure however is. Not only do data formats changes over time, but also do different
devices and vendors come with different formats. Using a digital twin platform, allows you to normalize the data,
and structure it in the way it is best for your use case.

And once you did that, you suddenly notice that you can work quite differently with your data. Especially if you have
the capabilities that Ditto offers, like listening for state changes, or reconciling actual vs desired state.

Sure you can "manually" do this in a small application. But with that, you just re-create parts of a digital twin
platform. Any in most cases, over and over again.

### MQTT between Ditto and Streamsheets

Instead of using the Streamsheets internal MQTT broker, it would also be possible to use Kafka again as the way deliver
changes from Ditto to Streamsheets, as both projects support Kafka too.

As Streamsheets is the only consumer of the data in this example, we kept the internal MQTT broker of Streamsheets.
Simply because it is Mosquitto, which too is an Eclipse IoT project.

### Visualization

Of course, what also comes in one's mind is Grafana. First of all, most people already know it by now. Second, it is better suited
for time services data. And in this example, we are focusing more on structured telemetry data. True, a single
temperature value isn't that complex. However, you have all the code and tools available to extend this.

## What else?

There are a few more projects and alternatives we could have used. Maybe you can add them?!

### Eclipse Kapua

We deployed the Kura gateway directly using a container. If you read on, there is a reason for that.

However, you could also install Kura directly on your gateway hardware, and have it managed by
[Eclipse Kapua](https://eclipse.org/kapua/).

### Eclipse ioFog

ioFog is an edge orchestration platform. Instead of manually running a Kura container, we could use it do manage
Kura as an edge workload.

We hope we can add ioFog, once version 3.0 is released. We do require some new tweaks, which will only be available
in the newer version.

### Time series database

In order to build up a history of all measured and reported temperature values and make this history accessible in an
optimized way for asking advanced queries (e.g. using filtering, aggregation, grouping and downsampling), a time series
database is the obvious choice to store data in an optimized way.

You can create another connection in Ditto, additionally to the MQTT connection which sends data to Streamsheets.
But this time, using an HTTP outbound connection. As Ditto supports formatting the outbound data with a JavaScript
snippet too, it is easy to generate a [CloudEvent](https://cloudevents.io/) from the Ditto change event.

Directing the CloudEvent towards a [Knative](https://knative.dev) service, changes can be pushed directly into a
[TimescaleDB](https://www.timescale.com/) instance, using the [serverless function for pushing to PostgreSQL](https://github.com/drogue-iot/drogue-postgresql-pusher) (of course you can also push to other time series database with that approach,
or even to other serverless functions or services, which accept CloudEvents).

Finishing up by creating a nice dashboard with [Grafana](https://grafana.com/), based on this data.

{% endcapture %}

{% capture aside %}
{% include toc.html sticky=true %}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
