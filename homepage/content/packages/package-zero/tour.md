---
title: 'Take a tour'
date: 2019-10-17T14:51:12+2:00
---

{{<row>}}

{{<col "12,md-8,lg-9">}}

{{<alert "warning" "Under construction">}}
This tutorial is still under construction, and not finished yet.
Of course, your are still welcome to it. Take a look and give some feedback.

---

<p class="mb-0">
Just be aware, that some content might still be missing, change over time,
or that you might experience some issues when testing.
</p>

{{</alert>}}

The following examples will use information which depends on your
environment. All of this information is listed in this section, and will be
set as environment variables, so that all command using it, can make use
of those variables:

{{<variants "Minikube,Kubernetes,OpenShift">}}

{{<variant "Minikube">}}
{{<clipboard>}}
    DEVICE_REGISTRY_URL=$(minikube service -n package-zero package-zero-service-device-registry-ext --url --https | grep 31443)
    MQTT_ADAPTER_HOST=$(minikube service -n package-zero package-zero-adapter-mqtt-vertx --url | grep 30883 | sed -e 's/^http:\/\///' -e 's/:.*$//')
    MQTT_ADAPTER_PORT=30883
{{</clipboard>}}
{{</variant>}}

{{<variant "Kubernetes">}}
{{<clipboard>}}
    DEVICE_REGISTRY_URL=https://$(kubectl get service package-zero-service-device-registry-ext --output='jsonpath={.status.loadBalancer.ingress[0].ip}' -n package-zero):28080
    MQTT_ADAPTER_HOST=$(kubectl get service package-zero-adapter-mqtt-vertx --output='jsonpath={.status.loadBalancer.ingress[0].ip}' -n package-zero)
    MQTT_ADAPTER_PORT=8883
{{</clipboard>}}
{{</variant>}}

{{<variant "OpenShift">}}
{{<clipboard>}}
    DEVICE_REGISTRY_URL=https://$(oc get -n package-zero route package-zero-service-device-registry-https --template='{{.spec.host}}')
    MQTT_ADAPTER_URL=$(oc -n package-zero get route package-zero-adapter-http-vertx-sec --template='{{.spec.host}}')
    MQTT_ADAPTER_PORT=443
{{</clipboard>}}
{{</variant>}}

{{</variants>}}

## Working with devices

The next sections will create a new tenant and register a device for it.

### Create a new tenant

Create a new tenant named `my-tenant`:

{{<clipboard>}}
    curl -i --insecure -XPOST ${DEVICE_REGISTRY_URL}/v1/tenants/my-tenant
{{</clipboard>}}

This should return a result of `201 Created`.

{{<details "Example of a successful result">}}
    HTTP/1.1 201 Created
    etag: be547a07-4a03-4c43-a274-d02f63f8d467
    location: /v1/tenants/my-tenant
    content-type: application/json; charset=utf-8
    content-length: 12
    
    {"id":"my-tenant"}
{{</details>}}

### Register a new device

Next we can register a new device, named `my-device-1` for the tenant we just created:

{{<clipboard>}}
    curl -i --insecure -XPOST ${DEVICE_REGISTRY_URL}/v1/devices/my-tenant/my-device-1
{{</clipboard>}}

This should return a result of `201 Created`.

{{<details "Example of a successful result">}}
    HTTP/1.1 201 Created
    etag: d48f4e13-b398-4c73-bbc3-5ac97a81b3e8
    location: /v1/devices/iot/my-device-1
    content-type: application/json; charset=utf-8
    content-length: 17
    
    {"id":"my-device-1"}
{{</details>}}

### Set device credentials

The device created has no credentials assigned. So it will not be possible for this
device to directly connect to the platform. This is ok for devices attached via
a *gateway device*, but we want this device to be able to connect, so the next step is
to assign a username/password combination:

{{<clipboard>}}
    curl -i --insecure -XPUT ${DEVICE_REGISTRY_URL}/v1/credentials/my-tenant/my-device-1 \
      -H "Content-Type: application/json" --data-binary @- <<__EOF__
    [{
      "type": "hashed-password",
      "auth-id": "my-auth-id-1",
      "secrets": [{
        "salt": "Mq7wFw==",
        "pwd-hash": "AQIDBAUGBwg=",
        "hash-function": "sha-512"
      }]
    }]
    __EOF__
{{</clipboard>}}

{{<details "Example of a successful result">}}
    HTTP/1.1 204 No Content
    etag: a7edc4b8-701a-4fe1-85c4-1717c0d24562
{{</details>}}

### Understanding identities

The previous step assigned the credentials of `my-auth-id-1` and `password` to the device `my-device-1`.

Please note that there is a difference between the *username* of the device (`my-auth-id-1`) and
the name of the device (`my-device-1`). When connecting to e.g. the MQTT protocol adapter,
you will need to use the full qualified username of `my-auth-id-1@my-tenant`
(*authentication id* and *tenant name*), rather than the "device id" (`my-device-1`).

The *authentication id* is only used for the authentication process. Later on, the messages will be marked
with the *device id*, and the backend system isn't aware of the *authentication id* anymore.

Of course you may use the same value for the *authentication id* and the *device id*. In this tutorial however,
we use distinct values to show the difference. 

## Working with data

Now that the device is registered, and has credentials set up, we can start publishing data.

### Start consumer

### Publish telemetry data via MQTT

Publish a telemetry message using the MQTT endpoint:

{{<clipboard>}}
    mosquitto_pub --insecure -h ${MQTT_ADAPTER_HOST} -p ${MQTT_ADAPTER_PORT} \
      -u my-auth-id-1@my-tenant -P my-password \
      --cafile charts/eclipse-hono/hono-demo-certs-jar/root-cert.pem \
      -t telemetry -m '{"temperature": 5}'
{{</clipboard>}}

{{<alert "info">}}
Although a certificate is provided, **insecure** is still required because
the hostname would not match the certificate.
{{</alert>}}

## Fetch from Digital twin

## Updating the firmware

{{</col>}}

{{<col "12,md-4,lg-3" "d-none d-md-block">}}
{{<toc sticky="true">}}
{{</col>}}

{{</row>}}
