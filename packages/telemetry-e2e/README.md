# Eclipse IoT – telemetry end-to-end

TODO: Move to proper documentation.

## Start cluster

### Minikube

Start a new Minikube instance:

    #minikube delete && minikube start --cpus 2 --memory 7168 --disk-size 20gb --addons ingress
    minikube delete && minikube start --cpus 4 --memory 8192 --disk-size 20gb --addons ingress

Run tunnel (and keep it running, e.g. in a separate terminal):

    minikube tunnel

Open the external port on your machine to receive MQTT traffic:

    sudo firewall-cmd --add-port=1883/tcp

Port-forward the MQTT port to the local cluster:

    kubectl port-forward deployment/mqtt-endpoint --address 0.0.0.0 1883

## Define domain

### Minikube

    DOMAIN=.$(minikube ip).nip.io # bash
    set DOMAIN .(minikube ip).nip.io # fish

**NOTE:** When you re-create the cluster, be sure to update the `DOMAIN` variable!

## Deploy cluster

### Minikube

Deploy:

    helm upgrade --install eclipse-iot-telemetry . \
      -f profiles/minikube.yaml \
      --timeout 30m \
      --set global.domain=$DOMAIN \
      --set iofog.ingress.domain=$DOMAIN

## Drogue IoT Cloud

Log in to the cluster:

    drg login http://api

Create a new device:

    drg create device --app eclipse device-1  --spec '{"credentials": {"credentials":[{ "pass": "foobar" }]}}'

## Push some data

    http --auth device-1@eclipse:foobar POST $(drg whoami -e http)/v1/foo temp:=42

## Fetch from Ditto

    curl -sL -X GET "http://ditto-default$DOMAIN/api/2/things/eclipse:device-1" -H  "accept: application/json" -H  "Authorization: Basic ZGl0dG86ZGl0dG8=" | jq

## Eclipse Kura

**NOTE:** This section describes how to run Kura "manually" using a container. It doesn't yet describe how to run it
inside ioFog.

**Requirements**: For this you will need a Bluetooth enabled Linux device with Docker installed. A simple
Raspberry Pi 3+ will work.

### Starting

Create and start the Kura container using:

    docker run -dti -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket --name kura -p 443:443 ghcr.io/ctron/kura-test:0.1.0 -console -consoleLog

It will start in the background. When the container should get stopped, you can restart it with the following command:

    docker start kura

### Login to the web console

Once it is fully started, you can also connect to using your web browser:

    https://<host-ip>

**NOTE:** Your browser will warn you about a self-signed certificate. That is ok in this case.

The default access credentials are:

  * Username: `admin`
  * Password: `admin` 

**NOTE:** You can change those credentials using the Web UI.

### Attaching to the console

You can attach to the console of Kura using:

    docker attach --sig-proxy=false kura

### Setup connection

Kura needs to be connected to the Drogue IoT cloud instance. The configuration must be done using the Web UI. The
following steps will walk you through the process.

#### Connecting the gateway

* Navigate to <menu>System > Cloud Connections</menu> and then select the tab labeled "MqttDataTransport".

* Set the following fields:

  <dl>
    <dt>Broker-url</dt><dd></dd>
    <dt>Username</dt><dd><code>device-1@eclipse</code></dd>
    <dt>Password</dt><dd><code>device12</code></dd>
  </dl>

* Afterwards click on <kbd>Apply</kbd> and confirm to store the settings.

* Next, test the settings by manually connecting. Click on the button <kbd>Connect/Disconnect</kbd> once, and wait.

* When the column status changes to "Connected" you can move on to the next step. Otherwise check the connection settings.

#### Creating a cloud publisher

* Navigate to <menu>System > Cloud Connections</menu> and click on the button <kbd>New Pub/Sub</kbd>.

* In the dialog, select `org.eclipse.kura.cloud.publisher.CloudPublisher` as a factory, and enter the new ID `microbit`.

* Confirm using the <kbd>Apply</kbd> button.

#### Configuring the micro:bit demo

* Navigate to <menu>Services > micro:bit</menu> and update the following settings:

  <dl>
    <dt>CloudPublisher Target Filter</dt><dd>Select the target <code>(kura.service.pid=microbot)</code></dd>
    <dt>Enabled</dt><dd><code>true</code></dd>
  </dl>

* Afterwards click on <kbd>Apply</kbd> and confirm to store the settings.

## ioFog

**NOTE:** The following is still work in progress and does not work.

Download Raspberry Pi image:

    wget https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip

Flash:

    xzcat 2021-05-07-raspios-buster-armhf-lite.img.xz | sudo dd of=/dev/sdb bs=1M status=progress oflag=sync

Enable SSH:

    touch boot/ssh

Enable WiFi:

  * Create a new file

        vi boot/wpa_supplicant.conf

  * Edit configuration

        country=DE # your ISO 3166 country code
        ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
        update_config=1
        network={
          ssid="<your ssid>"
          psk="<your password>"
        }

Install Agent:

```shell
sudo apt-get install docker.io
sudo usermod -aG docker ${USER}
```

Create repository file (`/etc/apt/sources.list.d/iofog-agent.list`):

```shell
cat << __EOF__ > /etc/apt/sources.list.d/iofog-agent.list
deb https://packagecloud.io/iofog/iofog-agent/raspbian/ buster main
deb-src https://packagecloud.io/iofog/iofog-agent/raspbian/ buster main
__EOF__
```

Add the key:

```shell
curl -sL https://packagecloud.io/iofog/iofog-agent/gpgkey | apt-key add -
```

Install the package:

```shell
apt-get update
apt-get install iofog-agent=2.0.7
```

Install Agent:

Fix `default-router`:

~~~shell
TOKEN=$(kubectl exec  -c controller deployment/iofog-controller -- iofog-controller user generate-token -e admin@my.cluster | jq -r .accessToken)
http -v PUT http://api-default.192.168.39.233.nip.io:80/api/v3/router Authorization:$TOKEN host=router-default.192.168.39.233.nip.io

kubectl exec  -c controller deployment/iofog-controller -- bash -c '
curl -XPUT http://localhost/api/v3/router -H Authorization $TOKEN 
iofog-controller user generate-token -e admin@my.cluster | jq -r .accessToken
'
~~~

Copy ssh keys:

~~~shell
ssh-copy-id pi@raspberrypi.fritz.box
~~~

~~~yaml
apiVersion: iofog.org/v2
kind: Agent
metadata:
  name: node-1
spec:
  host: my-raspberry-pi
  ssh:
    user: pi
    keyFile: ~/.ssh/id_rsa
~~~
