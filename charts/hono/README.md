# Eclipse Hono

[Eclipse Hono™](https://www.eclipse.org/hono/) provides remote service interfaces for connecting large
numbers of IoT devices to a back end and interacting with them in a uniform way regardless of the device
communication protocol.

This repository contains a *chart* that can be used to install Hono to a Kubernetes cluster using the
[Helm package manager](https://helm.sh).

## Prerequisites

Installing Hono using the chart requires the Helm tool to be installed as described on the
[IoT Packages chart repository prerequisites](https://www.eclipse.org/packages/prereqs/)
page.

In addition, a Kubernetes cluster to install the chart to is required.
Hono's [Kubernetes setup guide](https://www.eclipse.org/hono/docs/deployment/create-kubernetes-cluster/)
describes options available for setting up a cluster suitable for running Hono.

The Helm chart is being tested to successfully install on the five most recent Kubernetes versions.

## Installing the chart

Helm can be used to install applications multiple times to the same cluster. Each such
installation is called a *release* in Helm. Each release needs to have a unique name within
a Kubernetes name space.

The instructions below illustrate how Hono can be installed to the `hono` name space
in a Kubernetes cluster using release name `eclipse-hono`. The commands can easily be adapted
to use a different name space or release name.

1. The target name space in Kubernetes only needs to be created if it doesn't exist yet:
   ```bash
   kubectl create namespace hono
   ```
1. Install the chart to name space `hono` using release name `eclipse-hono`:
   ```bash
   helm install eclipse-hono eclipse-iot/hono -n hono --wait
   ```

## Verifying the Installation

Once installation has completed, Hono's external API endpoints are exposed via corresponding
Kubernetes *Services*. The following command lists all services and their endpoints
(replace `hono` with the name space that you have installed to):

```bash
kubectl get service -n hono

NAME                                            TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                           AGE
eclipse-hono-adapter-amqp                       LoadBalancer   10.99.197.79    127.0.0.1     5672:32672/TCP,5671:32671/TCP     2m30s
eclipse-hono-adapter-http                       LoadBalancer   10.102.247.45   127.0.0.1     8080:30080/TCP,8443:30443/TCP     2m29s
eclipse-hono-adapter-mqtt                       LoadBalancer   10.98.68.57     127.0.0.1     1883:31883/TCP,8883:30883/TCP     2m29s
eclipse-hono-kafka                              ClusterIP      10.104.176.12   <none>        9092/TCP                          2m30s
eclipse-hono-kafka-0-external                   LoadBalancer   10.98.132.252   127.0.0.1     9094:32094/TCP                    2m29s
eclipse-hono-kafka-headless                     ClusterIP      None            <none>        9092/TCP,9093/TCP                 2m30s
eclipse-hono-service-auth                       ClusterIP      10.99.220.217   <none>        5671/TCP                          2m29s
eclipse-hono-service-command-router             ClusterIP      10.98.52.92     <none>        5671/TCP                          2m29s
eclipse-hono-service-device-registry            ClusterIP      10.109.46.233   <none>        5671/TCP,8080/TCP,8443/TCP        2m29s
eclipse-hono-service-device-registry-ext        LoadBalancer   10.97.217.173   127.0.0.1     28080:31080/TCP,28443:31443/TCP   2m29s
eclipse-hono-service-device-registry-headless   ClusterIP      None            <none>        <none>                            2m30s
eclipse-hono-zookeeper                          ClusterIP      10.104.9.153    <none>        2181/TCP,2888/TCP,3888/TCP        2m29s
eclipse-hono-zookeeper-headless                 ClusterIP      None            <none>        2181/TCP,2888/TCP,3888/TCP        2m30s
```

The listing above has been retrieved from a Minikube cluster that emulates a load balancer via the `minikube tunnel`
command (refer to the [Minikube docs](https://minikube.sigs.k8s.io/docs/tasks/loadbalancer/) for details).
The service endpoints can be accessed at the *EXTERNAL-IP* addresses and corresponding *PORT(S)*, e.g. 8080 for the
HTTP adapter (*hono-adapter-http*) and 28080 for the device registry (*hono-service-device-registry*).

The following command assigns the IP address of the device registry service to the `REGISTRY_IP` environment
variable so that it can easily be used from the command line:

```bash
export REGISTRY_IP=$(kubectl get service eclipse-hono-service-device-registry-ext --output='jsonpath={.status.loadBalancer.ingress[0].ip}' -n hono)
```

The following command can then be used to check for the existence of the *DEFAULT_TENANT* which is created as part
of the installation:

```bash
curl -sIX GET http://$REGISTRY_IP:28080/v1/tenants/DEFAULT_TENANT
```

the output should look similar to

```
HTTP/1.1 200 OK
etag: 89d40d26-5956-4cc6-b978-b15fda5d1823
content-type: application/json; charset=utf-8
content-length: 260
```

## Uninstalling the Chart

To uninstall/delete the `eclipse-hono` release from the target name space:

```bash
helm uninstall eclipse-hono -n hono
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Release Notes

### 2.0.0

* The chart now uses Helm API version 2 and thus requires at least Helm version 3 to install.
* The chart has been adapted to support Hono 2.0.0 container images. Previous versions of Hono are no longer supported
  by the chart. All properties for configuring components that are not part of Hono 2.0.0 have been removed as well.
  In particular, this affects properties for the Device Connection service, the Kura protocol adapter and the file based
  device registry implementation.
* The *dataGridSpec* configuration property has been removed. The *commandRouterService.hono.commandRouter.cache*
  property now is the only place to use for configuring the connection to a remote cache.
* The *extraSecretMounts* property that was available for most components has been replaced with the *extraVolumes* and
  *extraVolumeMounts* properties which allow mounting any kind of volume supported by kubernetes into the container file
  system.

## Configuration

The chart's `values.yaml` file contains all possible configuration values along with documentation.

In order to set a property to a non-default value, the `--set key=value[,key=value]` command line parameter can be passed to
`helm install`. For example:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set useLoadBalancer=false
```

Alternatively, one or more YAML files that contain the properties can be provided when installing the chart:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait -f /path/to/config.yaml -f /path/to/other-config.yaml
```

## Enabling or disabling Protocol Adapters

The Helm chart by default installs the HTTP, MQTT and AMQP protocol adapters.
However, the chart also supports deployment of additional protocol adapters which are still considered experimental or
have been deprecated.
The following table provides an overview of the corresponding configuration properties that need to be set during installation.

| Property                     | Default  | Description                              |
| :--------------------------- | :------- | :--------------------------------------- |
| *adapters.amqp.enabled*      | `true`    | Indicates if the AMQP protocol adapter should be deployed. |
| *adapters.coap.enabled*      | `false`   | Indicates if the CoAP protocol adapter should be deployed. |
| *adapters.http.enabled*      | `true`    | Indicates if the HTTP protocol adapter should be deployed. |
| *adapters.lora.enabled*      | `false`   | Indicates if the (experimental) LoRa WAN protocol adapter should be deployed. |
| *adapters.mqtt.enabled*      | `true`    | Indicates if the MQTT protocol adapter should be deployed. |

The following command will deploy the LoRa adapter along with Hono's standard adapters (AMQP, HTTP and MQTT):

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set adapters.lora.enabled=true
```

## Using a production grade Kafka Cluster and Device Registry

The Helm chart by default deploys the example Device Registry that comes with Hono. The example registry provides implementations
of the Tenant, Device Registration and Credentials APIs which can be used for example/demo purposes.

The chart also deploys example messaging infrastructure consisting of a single Apache Kafka broker and an Apache Zookeeper
instance.

The protocol adapters are configured to connect to the example messaging infrastructure and registry by default.

In a production environment, though, usage of the example registry and messaging infrastructure is strongly discouraged and more
sophisticated (custom) implementations of the service APIs should be used.

The Helm chart supports configuration of the protocol adapters to connect to other service implementations than the example registry
and messaging infrastructure as described in the following sections.

### Integrating with an existing Kafka Cluster

The Helm chart can be configured to use an existing Kafka cluster instead of the example deployment.
In order to do so, the protocol adapters need to be configured with information about the bootstrap server addresses
and configuration properties.

The easiest way to set these properties is by means of putting them into a YAML file with content like this:

```yaml
# configure protocol adapters for Kafka messaging
messagingNetworkTypes:
- "kafka"

# do not deploy example AMQP Messaging Network
amqpMessagingNetworkExample:
  enabled: false

# do not deploy example Kafka cluster
kafkaMessagingClusterExample:
  enabled: false

adapters:
  # provide connection params
  kafkaMessagingSpec:
    commonClientConfig:
      bootstrap.servers: "broker0.my-custom-kafka.org:9092,broker1.my-custom-kafka.org:9092"
```

*adapters.kafkaMessagingSpec* needs to contain configuration properties as described in Hono's
[Kafka client admin guide](https://www.eclipse.org/hono/docs/admin-guide/hono-kafka-client-configuration/).
Make sure to adapt/add properties as required by the Kafka cluster.

Assuming that the file is named `customKafkaCluster.yaml`, the values can then be passed in to the Helm `install`
command as follows:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait -f /path/to/customKafkaCluster.yaml
```


### Integrating with a custom Device Registry

The Helm chart can be configured to use existing implementations of the Tenant, Device Registration and Credentials APIs
instead of the example device registry.
In order to do so, the protocol adapters need to be configured with information about the service endpoints and connection
properties.

The easiest way to set these properties is by means of putting them into a YAML file with the following content:

```yaml
# do not deploy example Device Registry
deviceRegistryExample:
  enabled: false

adapters:

  # mount (existing) Kubernetes secret which contains
  # credentials for connecting to services to all enabled adapters
  http:
    extraVolumes:
    - name: "custom-registry"
      secret:
        secretName: "custom-http-secret"
    extraVolumeMounts:
    - name: "custom-registry"
      mountPath: "/etc/custom"

  mqtt:
    extraVolumes:
    - name: "custom-registry"
      secret:
        secretName: "custom-mqtt-secret"
    extraVolumeMounts:
    - name: "custom-registry"
      mountPath: "/etc/custom"

  # provide connection params
  # assuming that "custom-*-secret" contains an "adapter.credentials" file
  tenantSpec:
    host: my-custom.registry.org
    port: 5672
    trustStorePath: "/etc/custom/registry-trust-store.pem"
    credentialsPath: "/etc/custom/adapter.credentials"
  deviceRegistrationSpec:
    host: my-custom.registry.org
    port: 5672
    trustStorePath: "/etc/custom/registry-trust-store.pem"
    credentialsPath: "/etc/custom/adapter.credentials"
  credentialsSpec:
    host: my-custom.registry.org
    port: 5672
    trustStorePath: "/etc/custom/registry-trust-store.pem"
    credentialsPath: "/etc/custom/adapter.credentials"
```

All of the *specs* need to contain Hono client configuration properties as described in the
[client admin guide](https://www.eclipse.org/hono/docs/admin-guide/hono-client-configuration/).
Make sure to adapt/add properties as required by the custom service implementations.
The information contained in the *specs* will then be used by all protocol adapters that get deployed.

Note that *custom-http-secret* and *custom-http-secret* are expected to already exist in the name space
that Hono gets installed to, i.e. the Helm chart will **not** create these secrets. Also note that even
if the two secrets both contain a file *adapter.properties*, the content of these files can be specific
to each adapter, i.e. the adapters can still use credentials that are specific to the type of adapter.

Assuming that the file is named `customRegistry.yaml`, the values can then be passed to the Helm 3 `install` command
as follows:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait -f /path/to/customRegistry.yaml
```


## Using AMQP 1.0 based Messaging Infrastructure

The chart can be configured to use AMQP 1.0 based messaging infrastructure instead of a Kafka broker.
The configuration `messagingNetworkTypes[0]=amqp` deploys Hono configured to use AMQP 1.0 for messaging.
It is possible to enable both Kafka _and_ AMQP based messaging at the same time using command line parameters
`--set messagingNetworkTypes[0]=kafka --set messagingNetworkTypes[1]=amqp`. Each tenant in Hono can then be
[configured](https://www.eclipse.org/hono/docs/admin-guide/hono-kafka-client-configuration/#configure-for-kafka-based-messaging)
separately to use either Kafka _or_ AMQP for messaging.

The following command provides a quick start for AMQP 1.0 based messaging (ensure `minikube tunnel` is running when using
Minikube):

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set messagingNetworkTypes[0]=amqp --set kafkaMessagingClusterExample.enabled=false --set amqpMessagingNetworkExample.enabled=true
```

The parameters enable the deployment of a simple AMQP 1.0 based messaging infrastructure, disable the deployment of the Kafka
broker and configure adapters and services to use AMQP 1.0 based messaging.

To use the service type `NodePort` instead of `LoadBalancer`, the following parameters must be added:
`--set useLoadBalancer=false --set kafka.externalAccess.service.type=NodePort`.

### Integrating with an existing AMQP Messaging Network

The Helm chart can be configured to use an existing AMQP Messaging Network implementation instead of the example implementation.
In order to do so, the protocol adapters need to be configured with information about the AMQP Messaging Network's endpoint address
and connection parameters.

The easiest way to set these properties is by means of putting them into a YAML file with content like this:

```yaml
# configure protocol adapters for AMQP 1.0 based messaging
messagingNetworkTypes:
- "amqp"

# do not deploy example AMQP Messaging Network
amqpMessagingNetworkExample:
  enabled: false

# mount (existing) Kubernetes secret which contains
# credentials for connecting to AMQP network
# into Command Router and protocol adapter containers 
commandRouterService:
  extraVolumes:
  - name: "amqp-network"
    secret:
      secretName: "my-secret"
  extraVolumeMounts:
  - name: "amqp-network"
    mountPath: "/etc/custom"

adapters:
  http:
    extraVolumes:
    - name: "amqp-network"
      secret:
        secretName: "my-secret"
    extraVolumeMounts:
    - name: "amqp-network"
      mountPath: "/etc/custom"
  mqtt:
    extraVolumes:
    - name: "amqp-network"
      secret:
        secretName: "my-secret"
    extraVolumeMounts:
    - name: "amqp-network"
      mountPath: "/etc/custom"
  amqp:
    extraVolumes:
    - name: "amqp-network"
      secret:
        secretName: "my-secret"
    extraVolumeMounts:
    - name: "amqp-network"
      mountPath: "/etc/custom"

  # provide connection params
  # assuming that "my-secret" contains an "amqp-credentials.properties" file
  amqpMessagingNetworkSpec:
    host: my-custom.amqp-network.org
    port: 5672
    credentialsPath: "/etc/custom/amqp-credentials.properties"
  commandAndControlSpec:
    host: my-custom.amqp-network.org
    port: 5672
    credentialsPath: "/etc/custom/amqp-credentials.properties"
```

Both the *amqpMessagingNetworkSpec* and the *commandAndControlSpec* need to contain Hono client configuration properties
as described in the [client admin guide](https://www.eclipse.org/hono/docs/admin-guide/hono-client-configuration/).
Make sure to adapt/add properties as required by the AMQP Messaging Network.

Note that *my-secret* is expected to already exist in the name space that Hono gets installed to, i.e. the Helm chart
will **not** create this secret.

Assuming that the file is named `customAmqpNetwork.yaml`, the values can then be passed in to the Helm `install`
command as follows:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait -f /path/to/customAmqpNetwork.yaml
```


## Installing Prometheus and Grafana

The chart supports installation and configuration of an example Prometheus instance for collecting metrics from Hono's
components and a Grafana instance for visualizing the metrics on dashboards in a web browser.

Both Prometheus and Grafana are completely optional and are not required to run Hono. The following configuration
properties can be used to install the Prometheus and Grafana servers along with Hono:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set prometheus.createInstance=true --set grafana.enabled=true
```

### Accessing the Example Grafana Dashboard

Hono comes with an example Grafana dashboard which provides some insight into the messages flowing through the protocol
adapters. The following command needs to be run first in order to forward the Grafana service's endpoint to the local host:

```bash
kubectl port-forward service/eclipse-hono-grafana 3000 -n hono
```

The dashboard can then be opened by pointing your browser to `http://localhost:3000` using credentials `admin:admin`.



## Using specific Container Images

The chart can be customized to use container images other than the default ones.
This can be used to install an older version of the images or to install a Hono milestone
using the chart. It can also be used to install custom built images that need to be
pulled from a different (private) container registry.

The `values.yaml` file contains configuration properties for setting the container
image and tag names to use for Hono's components. The easiest way to override the version
of all Hono components in one go is to set the `honoImagesTag` and/or `honoContainerRegistry`
properties to the desired values during installation.

The following command installs Hono using custom built images published on a private registry with tag
*2.0.0-custom* instead of the ones indicated by the chart's *appVersion* property:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set honoImagesTag=2.0.0-custom --set honoContainerRegistry=my-registry:9090
```

It is also possible to define the image and tag names and container registry for each component separately.
The easiest way to do that is to create a YAML file that specifies the particular properties:

```yaml
deviceRegistryExample:
  # pull custom Device Registry image from private container registry
  imageName: my-hono/hono-service-device-registry-custom
  imageTag: 1.0.0
  containerRegistry: my-private-registry

authServer:
  # pull "older" release from Docker Hub
  imageName: eclipse/hono-service-auth
  imageTag: 1.12.2

# pull standard adapter images in version 2.0.0 from Docker Hub
adapters:
  amqp:
    imageName: eclipse/hono-adapter-amqp
    imageTag: 2.0.0
  coap:
    imageName: eclipse/hono-adapter-coap
    imageTag: 2.0.0
  http:
    imageName: eclipse/hono-adapter-http
    imageTag: 2.0.0
  mqtt:
    imageName: eclipse/hono-adapter-mqtt
    imageTag: 2.0.0
  lora:
    imageName: eclipse/hono-adapter-lora
    imageTag: 2.0.0
```

Assuming that the file is named `customImages.yaml`, the values can then be passed in to the
Helm `install` command as follows:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait -f /path/to/customImages.yaml
```

## Using Native Executable Images

The Hono container images that are used by default contain Java byte code that is being executed using a standard Java VM.
For most of the images there also exists a variant that contains a native OS executable that has been created from the
Java byte code using the [Graal project](https://www.graalvm.org)'s *native-image* compiler. These images start up
more quickly than their corresponding JVM based counterparts. However, for these images no *just-in-time* compilation
is taking place during runtime because the byte code has been compiled *ahead of time* already. Consequently, the code
can also not be optimized during runtime which may result in a reduced performance when compared to the JVM based images.

The Helm chart can be configured to use these *native* images by means of explicitly specifying the component's image
name as described in *Using specific Container Images*. The names of the images based on native executables are the
standard image names appended by `-native`.

## Configuring Storage for Command Routing Data

Hono needs to store information about the connection status of devices during runtime.
This kind of information is used for determining how [command & control](https://www.eclipse.org/hono/docs/concepts/command-and-control/)
messages, that are sent by business applications, can be routed to the protocol adapters that the target devices are connected to.

Hono's protocol adapters can use the [Command Router API](https://www.eclipse.org/hono/docs/api/command-router/) to supply
device connection information with which a Command Router service component can route command & control messages to the
protocol adapters that the target devices are connected to.

Hono comes with a ready to use implementation of the Command Router API which is used by default when
installing Hono using the Helm chart.

#### Using an Embedded Cache

By default, the Command Router service component uses an embedded cache for the command routing data. All data is kept
in-memory only and will therefore be lost after restarting the Command Router service.

**NB** With this configuration, only one Command Router service component instance can be used. For a storage
configuration suitable for production, with the possibility to use multiple instances, use the data grid configuration
as described below.

#### Using a Data Grid

The Command Router service component can also be configured to use a data grid for storing the command routing data.
The Helm chart supports deployment of an example data grid which can be used for experimenting by means of setting the
*dataGridExample.enabled* property to `true`:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set dataGridExample.enabled=true
```

This will deploy the data grid based Command Router service component.

The Command Router service component can also be configured to connect to an already existing data grid.
In this case the *commandRouterService.hono.commandRouter.cache* property needs to be configured with the data grid's
connection information.

## Jaeger Tracing

Hono's components are instrumented using OpenTracing to allow tracking of the distributed processing of messages flowing
through the system. The Hono chart can be configured to report tracing information via an OpenTelemetry Collector to the
[Jaeger tracing system](https://www.jaegertracing.io/). The *Spans* reported by the components can then be viewed in a
web browser.

The chart can be configured to deploy and use an example Jaeger back end by means of setting the
*jaegerBackendExample.enabled* property to `true` when installing Hono:

~~~sh
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set jaegerBackendExample.enabled=true
~~~

This will create a Jaeger back end instance suitable for testing purposes and will configure all deployed Hono
components to use the Jaeger back end. The example Jaeger back end server's environment variables
can be set via the chart's *jaegerBackendExample.env* property.

The following command can be used to return the IP address at which the Jaeger UI can be accessed in a
browser (ensure `minikube tunnel` is running when using minikube):

~~~sh
kubectl get service eclipse-hono-jaeger-query --output="jsonpath={.status.loadBalancer.ingress[0]['hostname','ip']}" -n hono
~~~

If no example Jaeger back end should be deployed but instead another (existing) tracing back end that is supported
by OpenTelemetry should be used, the chart's *otelCollectorAgentConfigMap* property can be set to the name of an
existing ConfigMap that contains a corresponding OpenTelemetry Collector configuration file under key `otel-collector-config.yaml`.
