---
title: 'Gateway'
layout: package-page
twitterTitle: Telemetry end-to-end | Installation
description: Installations instructions for the Telemetry end-to-end package.
---

{% capture main %}

The installation of Eclipse Kura™ will require a [Raspberry Pi 3+](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/).
Kura itself will run on other hardware too, and it should not be a problem to run this tutorial on an AMD64 device or
another 32bit or 64bit ARM device. However, the following instructions are tested with a Raspberry Pi 3+ and commands
maybe be different when you choose a different target.

What you do require however is a device with a Linux supported Bluetooth device attached, and support for running
containers.

## Network & IP addresses

Eclipse Kura, running on the Raspberry Pi, will need to connect to the MQTT endpoint running on your Minikube
cluster. As this cluster is running on your local machine, inside a virtual machine, Kura cannot directly access
the MQTT endpoint.

In order to establish a connection between Kura on the Raspberry Pi and the MQTT endpoint inside the Minikube
cluster VM, you will need to:

* Connect the Raspberry Pi to a network that can reach the machine your Minikube cluster runs on
* Open a port forward from your machines network interface, to the MQTT endpoint service
* Open this port on your machine's firewall

The port forward can easily be created using `kubectl` on the host machine running the Minikube VM:

{% clipboard %}
kubectl port-forward deployment/mqtt-endpoint --address 0.0.0.0 1883
{% endclipboard %}

{% alert info: Firewall %}

Assuming you have a firewall, you also need to open access to port <code>1883</code> from your local network.

{% alertdetails %}
<p>
On Linux, you can temporarily open a port using the following command:
</p>

{% clipboard %}
sudo firewall-cmd --add-port=1883/tcp
{% endclipboard %}

{% endalertdetails %}

{% endalert %}

## Set up the device

{% alert info: Alternate installation methods %}
The following instructions are the bare minimal instructions required to set up a new Raspberry Pi when using
a Linux machine. If you are unsure how this works, or don't use a Linux like environment, check out the standard <a href="https://www.raspberrypi.org/software/" target="_blank" class="alert-link">installation instructions for Raspberry Pi OS</a>.
{% endalert %}

Download a Debian "buster" based Raspberry OS image:

{% clipboard %}
wget https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip
{% endclipboard %}

And write it so an SD card:

{% alert warning: Possible data loss %}
The next command will erase the target disk or SD card. Be sure that you are specifying the correct target device you
want to flash the image to. Once the process of flashing has started, there is no way to undo these changes.
{% endalert %}

{% clipboard %}
# replace XXX with your SD card drive that you want to erase (e.g. sdb)
xzcat 2021-05-07-raspios-buster-armhf-lite.img.xz | sudo dd of=/dev/XXX bs=1M status=progress oflag=sync
{% endclipboard %}

Before you boot for the first time, ensure that you enable SSH:

{% clipboard %}
touch boot/ssh
{% endclipboard %}

Also, it is recommended to enable WiFi:

* Create a new file

  {% clipboard %}
vi boot/wpa_supplicant.conf
  {% endclipboard %}

* Edit configuration

  {% clipboard %}
country=&lt;XX&gt; # use your ISO 3166 country code, e.g. DE for Germany
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
&nbsp;&nbsp;ssid="&lt;your ssid&gt;"
&nbsp;&nbsp;psk="&lt;our password&gt;"
}
  {% endclipboard %}

## Boot and check access

Once you flashed the SD card, put it into your Raspberry Pi and ensure that you can log into the device remotely using
`ssh`.

Also, ensure that Docker is installed. If you are missing docker, you can easily install this be executing the
following command:

{% clipboard %}
sudo apt-get install docker.io
{% endclipboard %}

{% alert info: Accessing as non-root user  %}
<p>
By default, most installations of docker require a "root" user to manage containers.
<a href="https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user" target="_blank" class="alert-link">Read here</a>
to learn how to grant non-root users direct access to docker.
</p>
<p>Alternatively, you can issue the following docker commands as "root", or use <code>sudo</code> to achieve the same.</p>
{% endalert %}

## Install Kura

Kura is not installed directly on the gateway, but run inside a container. We do this, as we plan to amend the
tutorial in the future, using an edge orchestration solution to deploy the IoT workload. For now, we manually start
the container.

### Create the Kura container

Create and start the Kura container using:

{% clipboard %}
docker run -dti -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket --name kura -p 443:443 ghcr.io/ctron/kura-test:0.1.1 -console -consoleLog
{% endclipboard %}

It will start in the background. Should the container should get stopped, you can restart it with the following command:

{% clipboard %}
docker start kura
{% endclipboard %}

### Login to the web console

Once it is fully started, you can also connect to using your web browser:

    https://<host-ip>

{% alert secondary: Self-signed certificates %}
Your browser will warn you about a self-signed certificate. That is ok in this case, as the Kura instance doesn't
know its hostname, it uses a self-signed certificate to offer TLS. You can replace the certificate if you prefer. 
{% endalert %}

The default access credentials are:

* Username: `admin`
* Password: `admin`

{% alert secondary: Default passwords %}
Using the Web UI, you can of course change the username and password.
{% endalert %}

### Attaching to the container console

You can also attach to the console of Kura using:

{% clipboard %}
docker attach --sig-proxy=false kura
{% endclipboard %}

## Setup connection

Kura needs to be connected to the Drogue IoT cloud instance. The configuration must be done using the Web UI. The
following steps will walk you through the process.

### Connecting the gateway

* Navigate to [System > Cloud Connections] and then select the tab labeled "MqttDataTransport".

* Set the following fields:

  <dl class="row">
    <dt class="col-sm-3">Broker-url</dt>
    <dd class="col-sm-9">
      <p><code>mqtt://&lt;your-host-ip&gt;:1883</code></p>
      The IP address is the IP the machine you are running
      <code>kubectl port-forward</code> on.
    </dd>
    <dt class="col-sm-3">Username</dt>
    <dd class="col-sm-9"><code>device-1@eclipse</code></dd>
    <dt class="col-sm-3">Password</dt>
    <dd class="col-sm-9"><code>device12</code></dd>
  </dl>

* Afterwards click on <kbd>Apply</kbd> and confirm to store the settings.

* Next, test the settings by manually connecting. Click on the button <kbd>Connect/Disconnect</kbd> once, and wait.

* When the column status changes to "Connected" you can move on to the next step. Otherwise, check the connection settings.

### Creating a cloud publisher

* Navigate to [System > Cloud Connections] and click on the button <kbd>New Pub/Sub</kbd>.

* In the dialog, select `org.eclipse.kura.cloud.publisher.CloudPublisher` as a factory, and enter the new ID `microbit`.

* Confirm using the <kbd>Apply</kbd> button.

### Configuring the micro:bit demo

* Navigate to [Services > micro:bit] and update the following settings:

  <dl class="row">
    <dt class="col-sm-3">CloudPublisher Target Filter</dt>
    <dd class="col-sm-9">Select the target <code>(kura.service.pid=microbot)</code></dd>
    
    <dt class="col-sm-3">Enabled</dt>
    <dd class="col-sm-9"><code>true</code></dd>
  </dl>

* Afterwards click on <kbd>Apply</kbd> and confirm to store the settings.

## What is next?

Go to the next page and set up the micro:bit.

## When things go wrong

### Unable to connect gateway to the cluster

If the gateway cannot connect to the cluster here are a few things to check.

#### Check if the connection reaches the port forward

If the connection reaches the port forward, you should see a corresponding message on the console:

```shell
$ kubectl port-forward deployment/mqtt-endpoint --address 0.0.0.0 1883
Forwarding from 0.0.0.0:1883 -> 1883
Handling connection for 1883
```

If you don't see `Handling connection for 1883`, this means that the gateway cannot reach port `1883` on your local
machine. Possible causes for this can be a firewall blocking access to the port or a wrong IP address or port number
in the Kura configuration.

If you see the message, but see errors directly after it, this means that Kura was connecting to the correct address
and port, but something fails with the port forward. The error message should provide additional information.

{% endcapture %}

{% capture aside %}
{% include toc.html sticky=true %}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
