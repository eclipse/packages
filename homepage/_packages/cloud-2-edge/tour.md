---
title: 'Take a tour'
layout: package-page
---

{% capture main %}

{% alert warning: Under construction %}

This tutorial is still under construction, and not finished yet.
Of course, you are still welcome to try it. Take a look and give some feedback.

{% alertdetails %}
Just be aware that some content might still be missing, change over time
or that you might experience some issues when testing.
{% endalertdetails %}

{% endalert %}

The following examples will use information which depends on your
environment. All of this information is listed in this section and will be
set as environment variables so that all commands can easily make use
of those variables:

{% variants %}
{% variant Minikube %}
{% clipboard %}
DEVICE_REGISTRY_URL=$(minikube service -n cloud2edge c2e-service-device-registry-ext --url --https | grep 31443)
MQTT_ADAPTER_HOST=$(minikube service -n cloud2edge c2e-adapter-mqtt-vertx --url | grep 30883 | sed -e 's/^http:\/\///' -e 's/:.*$//')
MQTT_ADAPTER_PORT=30883
{% endclipboard %}
{% endvariant %}

{% variant Kubernetes %}
{% clipboard %}
DEVICE_REGISTRY_URL=https://$(kubectl get service c2e-service-device-registry-ext --output='jsonpath={.status.loadBalancer.ingress[0].ip}' -n cloud2edge):28080
MQTT_ADAPTER_HOST=$(kubectl get service c2e-adapter-mqtt-vertx --output='jsonpath={.status.loadBalancer.ingress[0].ip}' -n cloud2edge)
MQTT_ADAPTER_PORT=8883
{% endclipboard %}
{% endvariant %}

{% variant OpenShift %}
{% clipboard %}
DEVICE_REGISTRY_URL=https://$(oc get -n cloud2edge route c2e-service-device-registry-https --template='{{"{{.spec.host"}}}}')
MQTT_ADAPTER_URL=$(oc -n cloud2edge get route c2e-adapter-http-vertx-sec --template='{{"{{.spec.host"}}}}')
MQTT_ADAPTER_PORT=443
{% endclipboard %}
{% endvariant %}

{% endvariants %}

## Working with devices

The next sections will create a new tenant and register a device for it.

### Create a new tenant

Create a new tenant named `my-tenant`:

{% clipboard %}
curl -i --insecure -XPOST ${DEVICE_REGISTRY_URL}/v1/tenants/my-tenant
{% endclipboard %}

This should return a result of `201 Created`.

{% details Example of a successful result %}
    HTTP/1.1 201 Created
    etag: be547a07-4a03-4c43-a274-d02f63f8d467
    location: /v1/tenants/my-tenant
    content-type: application/json; charset=utf-8
    content-length: 12
    
    {"id":"my-tenant"}
{% enddetails %}

### Register a new device

Next we can register a new device, named `my-device-1` for the tenant we just created:

{% clipboard %}
    curl -i --insecure -XPOST ${DEVICE_REGISTRY_URL}/v1/devices/my-tenant/my-device-1
{% endclipboard %}

This should return a result of `201 Created`.

{% details Example of a successful result %}
    HTTP/1.1 201 Created
    etag: d48f4e13-b398-4c73-bbc3-5ac97a81b3e8
    location: /v1/devices/iot/my-device-1
    content-type: application/json; charset=utf-8
    content-length: 17
    
    {"id":"my-device-1"}
{% enddetails %}

### Set device credentials

The device created has no credentials assigned. So it will not be possible for this
device to directly connect to the platform. This is ok for devices attached via
a *gateway device*, but we want this device to be able to connect, so the next step is
to assign a username/password combination:

{% clipboard %}
    curl -i --insecure -XPUT ${DEVICE_REGISTRY_URL}/v1/credentials/my-tenant/my-device-1 \
      -H "Content-Type: application/json" --data-binary @- <<__EOF__
    [{
      "type": "hashed-password",
      "auth-id": "my-auth-id-1",
      "secrets": [{
        "pwd-plain": "my-password"
      }]
    }]
    __EOF__
{% endclipboard %}

{% details Example of a successful result %}
    HTTP/1.1 204 No Content
    etag: a7edc4b8-701a-4fe1-85c4-1717c0d24562
{% enddetails %}

### Understanding identities

The previous step assigned the credentials of `my-auth-id-1` and `my-password` to the device `my-device-1`.

Please note that there is a difference between the *username* of the device (`my-auth-id-1`) and
the name of the device (`my-device-1`). When connecting to e.g. the MQTT protocol adapter,
you will need to use the fully qualified username of `my-auth-id-1@my-tenant`
(*authentication id* and *tenant name*), rather than just the *device id* (`my-device-1`).

The *authentication id* is only used for the authentication process. Later on, the messages will be marked
with the *device id* and the back end system isn't aware of the *authentication id* anymore.

Of course you may use the same value for the *authentication id* and the *device id*. In this tutorial however,
we use distinct values to show the difference. 

## Working with data

Now that the device is registered, and has credentials set up, we can start publishing data.

### Start consumer

### Publish telemetry data via MQTT

Publish a telemetry message using the MQTT endpoint:

{% clipboard %}
    mosquitto_pub --insecure -h ${MQTT_ADAPTER_HOST} -p ${MQTT_ADAPTER_PORT} \
      -u my-auth-id-1@my-tenant -P my-password \
      --cafile charts/eclipse-hono/hono-demo-certs-jar/root-cert.pem \
      -t telemetry -m '{"temperature": 5}'
{% endclipboard %}

{% alert info: %}
Although a certificate is provided, <strong>insecure</strong> is still required because
the host name would not match the certificate.
{% endalert %}

## Fetch from Digital Twin

tbd

## Updating the firmware

tbd

{% endcapture %}

{% capture aside %}
{% include toc.html sticky=true %}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
