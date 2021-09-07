---
title: 'Using it'
layout: package-page
twitterTitle: Telemetry end-to-end | Understanding it
description: Go ahead and play with the package.
---

{% capture main %}

## Log in to the Drogue IoT console

The Helm installation command will print out the URL to the Drogue IoT console.

Go ahead and open it with your browser. The access credentials are printed put in the console too. If you didn't
change the defaults, they are:

<dl class="row">
    <dt class="col-sm-3">Username</dt>
    <dd class="col-sm-9"><code>admin</code></dd>
    <dt class="col-sm-3">Password</dt>
    <dd class="col-sm-9"><code>admin123456</code></dd>
</dl>

Take a look around and explore the console a bit.

## See it visualized

The micro:bit will acquire the ambient temperature. Streamsheets will visualize this information.

You can see the information when you open the Streamsheet for this package. Navigate to the Streamsheets console, it
is linked in the "Overview" section of the Drogue IoT console under the "Demos" column.

The default access credentials are:

<dl class="row">
    <dt class="col-sm-3">Username</dt>
    <dd class="col-sm-9"><code>admin</code></dd>
    <dt class="col-sm-3">Password</dt>
    <dd class="col-sm-9"><code>1234</code></dd>
</dl>

In the Streamsheets console, open the "Eclipse IoT" sheet. This will open a dynamic spreadsheet, showing the most
recent received temperature information.

On the left-hand side, you will find an "inbox" tab, which shows the complete message. And in the spreadsheets
section, the formatted data.

## Change the temperature

In order to change the current temperature, you need to get a bit creative.

<blockquote class="blockquote">
<p class="mb-0">Do not blow on the edge connector or touch with your fingers.</p>
<footer class="blockquote-footer">Most ignored warning on <cite title="Source Title">console cartridges</cite></footer>
</blockquote>

The temperature sensor on the micro:bit isn't very accurate, as it is highly influenced by the board temperature
itself. And that will get warmer when you power it.

Still, you have a bunch of options (licking it is not one of them!):

* Hold it in front of your desktop machine's or notebook's fan.
* Take it into another room (mind the Bluetooth connection to the Raspberry Pi)
* Put it on your heater (in case winter is coming!)

Whatever you do, the temperature should slowly change and that change should be visible in the streamsheets spreadsheet.

## What is next?

You not only installed, but also took a brief look on what you installed.

Take a look at the next pages, to understand a bit more on how any why things are done as they are. At the end, you
should have all the pointer to take the next step.

{% endcapture %}

{% capture aside %}
{% include toc.html sticky=true %}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
