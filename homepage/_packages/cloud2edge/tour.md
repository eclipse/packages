---
title: 'Take a tour'
layout: package-page
twitterTitle: Cloud2Edge | Take a tour
description: Take a tour once you installed the Cloud2Edge package.
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

## Preparing the environment

The following examples will use information which depends on your
environment. All of this information is listed in this section and will be
set as environment variables so that all commands can easily make use
of those variables. Note that you will need to set the environment variables
in every command shell separately.

{% variants %}

{% variant Kubernetes %}
<br>
Download the [setCloud2EdgeEnv script](../scripts/setCloud2EdgeEnv.sh) and use it
to set environment variables for the Cloud2Edge package's service endpoints.

{% clipboard %}
RELEASE=c2e
NS=cloud2edge
./setCloud2EdgeEnv.sh $RELEASE $NS
{% endclipboard %}
{% endvariant %}

{% variant OpenShift %}
{% clipboard %}
NS=cloud2edge
RELEASE=c2e
DEVICE_REGISTRY_URL=https://$(oc get -n $NS route ${RELEASE}-service-device-registry-https --template='{{"{{.spec.host"}}}}')
HTTP_ADAPTER_URL=$(oc get -n $NS route ${RELEASE}-adapter-http-vertx-sec --template='{{"{{.spec.host"}}}}')
HTTP_ADAPTER_PORT=443
{% endclipboard %}
{% endvariant %}

{% endvariants %}

## Publishing telemetry data

The Cloud2Edge package comes with a pre-provisioned example device that we will use to publish
some telemetry data via Hono's HTTP protocol adapter. The data will automatically be forwarded to Ditto
where the device's twin representation will be updated with the data published by the device.

The demo device's digital twin supports a temperature property which will be set to 45
by means of the following command:

{% clipboard %}
curl -i -u demo-device@org.eclipse.packages.c2e:demo-secret -H 'application/json' --data-binary '{
  "topic": "org.eclipse.packages.c2e/demo-device/things/twin/commands/modify",
  "headers": {},
  "path": "/features/temperature/properties/value",
  "value": 45
}' http://${HTTP_ADAPTER_IP}:${HTTP_ADAPTER_PORT_HTTP}/telemetry
{% endclipboard %}

## Retrieving the digital twin's current state

The updated state of the digital twin can then be retrieved using:

{% clipboard %}
curl -u ditto:ditto -w '\n' http://$DITTO_API_IP:$DITTO_API_PORT_HTTP/api/2/things/org.eclipse.packages.c2e:demo-device
{% endclipboard %}

Alternatively you can also use the following command to subscribe to Ditto's
stream of thing update events:

{% clipboard %}
curl --http2 -u ditto:ditto -H 'Accept:text/event-stream' -N http://$DITTO_API_IP:$DITTO_API_PORT_HTTP/api/2/things
{% endclipboard %}

## Sending a command to the device via its digital twin

Ditto digital twin may also be used to send a command down to the device connected at Hono using.

{% clipboard %}
curl -i -X POST -u ditto:ditto -H 'Content-Type: application/json' -w '\n' --data '{
  "water-amount": "3liters"
}' http://$DITTO_API_IP:$DITTO_API_PORT_HTTP/api/2/things/org.eclipse.packages.c2e:demo-device/inbox/messages/start-watering?timeout=0
{% endclipboard %}

Specifying the `timeout=0` parameter indicates that the HTTP request will directly be accepted and Ditto does not wait
for a response.

If Ditto shall wait for a response, responding with the response from the device at the HTTP level, simply increase the
timeout to the amount of seconds to wait:

{% clipboard %}
curl -i -X POST -u ditto:ditto -H 'Content-Type: application/json' -w '\n' --data '{
  "water-amount": "3liters"
}' http://$DITTO_API_IP:$DITTO_API_PORT_HTTP/api/2/things/org.eclipse.packages.c2e:demo-device/inbox/messages/start-watering?timeout=60
{% endclipboard %}
 
### Receiving a command at the device

The device may receive a command by specifying a `ttd` when e.g. sending telemetry via HTTP to Hono:

{% clipboard %}
curl -i -u demo-device@org.eclipse.packages.c2e:demo-secret -H 'hono-ttd: 50' -H 'application/json' -w '\n' --data '{
  "topic": "org.eclipse.packages.c2e/demo-device/things/twin/commands/modify",
  "headers": {},
  "path": "/features/temperature/properties/value",
  "value": 45
}' http://${HTTP_ADAPTER_IP}:${HTTP_ADAPTER_PORT_HTTP}/telemetry
{% endclipboard %}

An example response for the device containing the command sent via the Ditto twin (see previous step for sending the 
command) is:

{% details Example of a received command at the device %}
    HTTP/1.1 200 OK
    hono-command: start-watering
    hono-cmd-req-id: 024d84b1ceb-797b-45f5-bc87-78e9b5396645replies
    content-type: application/json
    content-length: 516
    
    {"topic":"org.eclipse.packages.c2e/demo-device/things/live/messages/start-watering","headers":{"correlation-id":"d84b1ceb-797b-45f5-bc87-78e9b5396645","x-forwarded-for":"10.244.0.1","version":2,"timeout":"0","x-forwarded-user":"ditto","accept":"*/*","x-real-ip":"10.244.0.1","x-ditto-dummy-auth":"nginx:ditto","host":"172.17.0.2:30385","content-type":"application/json","timestamp":"2020-02-28T08:04:43.518+01:00","user-agent":"curl/7.58.0"},"path":"/inbox/messages/start-watering","value":{"water-amount":"3liters"}}
{% enddetails %}

### Responding to a command at the device

In order to answer to a command, the device can send its answer in Ditto Protocol back to Hono via HTTP.

The response has to be correlated twice:
* once for Hono in the URL: please replace the placeholder `insert-hono-cmd-req-id-here` with the `hono-cmd-req-id` 
  HTTP header value from the received command.
* once for Ditto in the Ditto Protocol payload: please replace the placeholder `insert-ditto-correlation-id-header-here`
  with the `"correlation-id"` value from the received Ditto Protocol message's `"headers"` object.

{% clipboard %}
curl -i -X PUT -u demo-device@org.eclipse.packages.c2e:demo-secret -H "content-type: application/json" --data-binary '{
  "topic": "org.eclipse.packages.c2e/demo-device/things/live/messages/start-watering",
  "headers": {
    "content-type": "application/json",
    "correlation-id": "insert-ditto-correlation-id-header-here"
  },
  "path": "/inbox/messages/start-watering",
  "value": {
    "starting-watering": true
  },
  "status": 200
}' http://${HTTP_ADAPTER_IP}:${HTTP_ADAPTER_PORT_HTTP}/command/res/org.eclipse.packages.c2e/org.eclipse.packages.c2e:demo-device/insert-hono-cmd-req-id-here?hono-cmd-status=200
{% endclipboard %}

An example message response (omitting some additional HTTP headers) at the Ditto twin which waited for the command
 e.g. with a `timeout=60` is:

{% details Example of a twin message response %}
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 26
    correlation-id: 715cb667-7750-4451-969e-6f8c735129ef

    {"starting-watering":true}
{% enddetails %}

## Working with devices

The next sections will create a new tenant in Hono, register a device for it and create a digital twin for it in Ditto.

In order to *link* Hono devices to Ditto digital twins (a.k.a. things), it is assumed that Hono device and Ditto thing 
always have the same id, starting with a namespace (e.g. in reverse domain notation), followed by a colon and a name, 
e.g.: `org.acme:my-device`.

### Create a new tenant

Create a new tenant named `my-tenant` in Hono:

{% clipboard %}
curl -i -X POST http://${REGISTRY_IP}:${REGISTRY_PORT_HTTP}/v1/tenants/my-tenant
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

Next we can register a new device, named `org.acme:my-device-1` for the tenant we just created:

{% clipboard %}
    curl -i -X POST http://${REGISTRY_IP}:${REGISTRY_PORT_HTTP}/v1/devices/my-tenant/org.acme:my-device-1
{% endclipboard %}

This should return a result of `201 Created`.

{% details Example of a successful result %}
    HTTP/1.1 201 Created
    etag: d48f4e13-b398-4c73-bbc3-5ac97a81b3e8
    location: /v1/devices/iot/org.acme:my-device-1
    content-type: application/json; charset=utf-8
    content-length: 17
    
    {"id":"org.acme:my-device-1"}
{% enddetails %}

#### Set device credentials

The device created has no credentials assigned. So it will not be possible for this
device to directly connect to the platform. This is ok for devices attached via
a *gateway device*, but we want this device to be able to connect, so the next step is
to assign a username/password combination:

{% clipboard %}
curl -i -X PUT -H "Content-Type: application/json" --data '[
{
  "type": "hashed-password",
  "auth-id": "my-auth-id-1",
  "secrets": [{
    "pwd-plain": "my-password"
  }]
}]' http://${REGISTRY_IP}:${REGISTRY_PORT_HTTP}/v1/credentials/my-tenant/org.acme:my-device-1
{% endclipboard %}

{% details Example of a successful result %}
    HTTP/1.1 204 No Content
    etag: a7edc4b8-701a-4fe1-85c4-1717c0d24562
{% enddetails %}

#### Understanding identities

The previous step assigned the credentials of `my-auth-id-1` and `my-password` to the device `org.acme:my-device-1`.

Please note that there is a difference between the *username* of the device (`my-auth-id-1`) and
the name of the device (`org.acme:my-device-1`). When connecting to e.g. the MQTT protocol adapter,
you will need to use the fully qualified username of `my-auth-id-1@my-tenant`
(*authentication id* and *tenant name*), rather than just the *device id* (`org.acme:my-device-1`).

The *authentication id* is only used for the authentication process. Later on, the messages will be marked
with the *device id* and the back end system isn't aware of the *authentication id* anymore.

Of course you may use the same value for the *authentication id* and the *device id*. In this tutorial however,
we use distinct values to show the difference. 

### Create a new connection from Ditto to Hono

In order to create digital twins in Ditto for a newly added Hono tenant, a new connection has to be created.

The `NS` and `RELEASE` variables must still be set to the value you chose during the [installation](../installation/#install-the-package).
The documented defaults are:
{% clipboard %}
NS=cloud2edge
RELEASE=c2e
{% endclipboard %}

Please also configure your chosen Hono tenant name [when your created a new tenant](#create-a-new-tenant) and extract
the Ditto devops password via `kubectl`:

{% clipboard %}
HONO_TENANT=my-tenant
DITTO_DEVOPS_PWD=$(kubectl --namespace ${NS} get secret ${RELEASE}-ditto-gateway-secret -o jsonpath="{.data.devops-password}" | base64 --decode)
{% endclipboard %}

Now, create the connection:

{% clipboard %}
curl -i -X POST -u devops:${DITTO_DEVOPS_PWD} -H 'Content-Type: application/json' --data '{
  "targetActorSelection": "/system/sharding/connection",
  "headers": {
    "aggregate": false
  },
  "piggybackCommand": {
    "type": "connectivity.commands:createConnection",
    "connection": {
      "id": "hono-connection-for-'"${HONO_TENANT}"'",
      "connectionType": "amqp-10",
      "connectionStatus": "open",
      "uri": "amqp://consumer%40HONO:verysecret@'"${RELEASE}"'-dispatch-router-ext:15672",
      "failoverEnabled": true,
      "sources": [
        {
          "addresses": [
            "telemetry/'"${HONO_TENANT}"'",
            "event/'"${HONO_TENANT}"'"
          ],
          "authorizationContext": [
            "pre-authenticated:hono-connection"
          ],
          "enforcement": {
            "input": "{%raw%}{{ header:device_id }}{%endraw%}",
            "filters": [
              "{%raw%}{{ entity:id }}{%endraw%}"
            ]
          },
          "headerMapping": {
            "hono-device-id": "{%raw%}{{ header:device_id }}{%endraw%}",
            "content-type": "{%raw%}{{ header:content-type }}{%endraw%}"
          },
          "replyTarget": {
            "enabled": true,
            "address": "{%raw%}{{ header:reply-to }}{%endraw%}",
            "headerMapping": {
              "to": "command/'"${HONO_TENANT}"'/{%raw%}{{ header:hono-device-id }}{%endraw%}",
              "subject": "{%raw%}{{ header:subject | fn:default(topic:action-subject) | fn:default(topic:criterion) }}{%endraw%}-response",
              "correlation-id": "{%raw%}{{ header:correlation-id }}{%endraw%}",
              "content-type": "{%raw%}{{ header:content-type | fn:default('"'"'application/vnd.eclipse.ditto+json'"'"') }}{%endraw%}"
            },
            "expectedResponseTypes": [
              "response",
              "error"
            ]
          },
          "acknowledgementRequests": {
            "includes": [],
            "filter": "fn:filter(header:qos,'"'"'ne'"'"','"'"'0'"'"')"
          }
        },
        {
          "addresses": [
            "command_response/'"${HONO_TENANT}"'/replies"
          ],
          "authorizationContext": [
            "pre-authenticated:hono-connection"
          ],
          "headerMapping": {
            "content-type": "{%raw%}{{ header:content-type }}{%endraw%}",
            "correlation-id": "{%raw%}{{ header:correlation-id }}{%endraw%}",
            "status": "{%raw%}{{ header:status }}{%endraw%}"
          },
          "replyTarget": {
            "enabled": false,
            "expectedResponseTypes": [
              "response",
              "error"
            ]
          }
        }
      ],
      "targets": [
        {
          "address": "command/'"${HONO_TENANT}"'",
          "authorizationContext": [
            "pre-authenticated:hono-connection"
          ],
          "topics": [
            "_/_/things/live/commands",
            "_/_/things/live/messages"
          ],
          "headerMapping": {
            "to": "command/'"${HONO_TENANT}"'/{%raw%}{{ thing:id }}{%endraw%}",
            "subject": "{%raw%}{{ header:subject | fn:default(topic:action-subject) }}{%endraw%}",
            "content-type": "{%raw%}{{ header:content-type | fn:default('"'"'application/vnd.eclipse.ditto+json'"'"') }}{%endraw%}",
            "correlation-id": "{%raw%}{{ header:correlation-id }}{%endraw%}",
            "reply-to": "{%raw%}{{ fn:default('"'"'command_response/'"${HONO_TENANT}"'/replies'"'"') | fn:filter(header:response-required,'"'"'ne'"'"','"'"'false'"'"') }}{%endraw%}"
          }
        },
        {
          "address": "command/'"${HONO_TENANT}"'",
          "authorizationContext": [
            "pre-authenticated:hono-connection"
          ],
          "topics": [
            "_/_/things/twin/events",
            "_/_/things/live/events"
          ],
          "headerMapping": {
            "to": "command/'"${HONO_TENANT}"'/{%raw%}{{ thing:id }}{%endraw%}",
            "subject": "{%raw%}{{ header:subject | fn:default(topic:action-subject) }}{%endraw%}",
            "content-type": "{%raw%}{{ header:content-type | fn:default('"'"'application/vnd.eclipse.ditto+json'"'"') }}{%endraw%}",
            "correlation-id": "{%raw%}{{ header:correlation-id }}{%endraw%}"
          }
        }
      ]
    }
  }
}' http://${DITTO_API_IP}:${DITTO_API_PORT_HTTP}/devops/piggyback/connectivity
{% endclipboard %}


### Create the digital twin

In the previous steps a device was registered in Hono, now we want to create a digital twin for this device in Ditto.

#### Setup a common policy

In order to define common authorization information for all digital twins about to be created in Ditto, we first create 
a policy with the id `org.acme:my-policy`:

{% clipboard %}
curl -i -X PUT -u ditto:ditto -H 'Content-Type: application/json' --data '{
  "entries": {
    "DEFAULT": {
      "subjects": {
        "{%raw%}{{ request:subjectId }}{%endraw%}": {
           "type": "Ditto user authenticated via nginx"
        }
      },
      "resources": {
        "thing:/": {
          "grant": ["READ", "WRITE"],
          "revoke": []
        },
        "policy:/": {
          "grant": ["READ", "WRITE"],
          "revoke": []
        },
        "message:/": {
          "grant": ["READ", "WRITE"],
          "revoke": []
        }
      }
    },
    "HONO": {
      "subjects": {
        "pre-authenticated:hono-connection": {
          "type": "Connection to Eclipse Hono"
        }
      },
      "resources": {
        "thing:/": {
          "grant": ["READ", "WRITE"],
          "revoke": []
        },
        "message:/": {
          "grant": ["READ", "WRITE"],
          "revoke": []
        }
      }
    }
  }
}' http://${DITTO_API_IP}:${DITTO_API_PORT_HTTP}/api/2/policies/org.acme:my-policy
{% endclipboard %}

This should return a result of `201 Created` containing as response body of the created policy JSON.

The created policy may be used for just one digital twin or for many of them. Modifying it will adjust the authorization
configuration of all twins referencing this *policy id*. 

#### Create the twin

In order to create a digital twin in Ditto, we use the same *device id* already used for creating the device at Hono as 
*thing id*: `org.acme:my-device-1`.<br>
Furthermore, we add a reference to the in the previous step created *policy id* in order to define the authorization 
information of the twin: 

{% clipboard %}
curl -i -X PUT -u ditto:ditto -H 'Content-Type: application/json' --data '{
  "policyId": "org.acme:my-policy",
  "attributes": {
    "location": "Germany"
  },
  "features": {
    "temperature": {
      "properties": {
        "value": null
      }
    },
    "humidity": {
      "properties": {
        "value": null
      }
    }
  }
}' http://${DITTO_API_IP}:${DITTO_API_PORT_HTTP}/api/2/things/org.acme:my-device-1
{% endclipboard %}

This should return a result of `201 Created` containing as response body of the created thing JSON.

In order to add more twins, we simply create additional devices via ["Register a new device"](#register-a-new-device)
and add twins for them with the above snippet by simply adjusting the *device id* and *thing id* in the URL of both
HTTP requests.

## Next Steps

* Check out the [User Guides of Hono's protocol adapters](https://www.eclipse.org/hono/docs/user-guide/) to learn more about
the device protocols that are supported by Hono.
* Learn about the [Ditto Protocol](https://www.eclipse.org/ditto/protocol-overview.html) which is used to interact with the
digital twins that are maintained by Ditto.

## Updating the firmware

tbd

{% endcapture %}

{% capture aside %}
{% include toc.html sticky=true %}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
