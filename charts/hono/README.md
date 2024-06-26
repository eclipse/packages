# Eclipse Hono

[Eclipse Hono™](https://www.eclipse.org/hono/) provides remote service interfaces for connecting large
numbers of IoT devices to a back end and interacting with them in a uniform way regardless of the device
communication protocol.

This repository contains a *chart* that can be used to install Hono to a Kubernetes cluster using the
[Helm package manager](https://helm.sh).

## Prerequisites

Installing Hono using the chart requires the Helm tool to be installed as described on the
[IoT Packages chart repository prerequisites](https://www.eclipse.org/packages/prereqs/#helm)
page.

In addition, a Kubernetes cluster to install the chart to is required.
See the corresponding section on the [IoT Packages prerequisites](https://www.eclipse.org/packages/prereqs/#kubernetes-cluster)
page for information on how to set up a cluster suitable for running Hono.

The Helm chart is being tested to successfully install on the four most recent Kubernetes versions.

## Installing the chart

Helm can be used to install applications multiple times to the same cluster. Each such
installation is called a *release* in Helm. Each release needs to have a unique name within
a Kubernetes namespace.

The instructions below illustrate how Hono can be installed to the `hono` namespace
in a Kubernetes cluster using release name `eclipse-hono`. The commands can easily be adapted
to use a different namespace or release name.

1. The target namespace in Kubernetes only needs to be created if it doesn't exist yet:
   ```bash
   kubectl create namespace hono
   ```
1. Install the chart to namespace `hono` using release name `eclipse-hono`:
   ```bash
   helm install eclipse-hono eclipse-iot/hono -n hono --wait
   ```

## Verifying the Installation

Once installation has completed, Hono's external API endpoints are exposed via corresponding
Kubernetes *Services*. The following command lists all services and their endpoints
(replace `hono` with the namespace that you have installed to):

```bash
kubectl get service -n hono

NAME                                            TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                           AGE
eclipse-hono-adapter-amqp                       LoadBalancer   10.99.197.79    127.0.0.1     5671:32671/TCP                    2m30s
eclipse-hono-adapter-http                       LoadBalancer   10.102.247.45   127.0.0.1     8443:30443/TCP                    2m29s
eclipse-hono-adapter-mqtt                       LoadBalancer   10.98.68.57     127.0.0.1     8883:30883/TCP                    2m29s
eclipse-hono-kafka                              ClusterIP      10.104.176.12   <none>        9092/TCP,9095/TCP                 2m30s
eclipse-hono-kafka-controller0-external         LoadBalancer   10.98.132.252   127.0.0.1     9094:32094/TCP                    2m29s
eclipse-hono-kafka-controller-headless          ClusterIP      None            <none>        9094/TCP,9092/TCP,9093/TCP        2m30s
eclipse-hono-service-auth                       ClusterIP      10.99.220.217   <none>        5671/TCP,8088/TCP                 2m29s
eclipse-hono-service-command-router             ClusterIP      10.98.52.92     <none>        5671/TCP                          2m29s
eclipse-hono-service-device-registry            ClusterIP      10.109.46.233   <none>        5671/TCP,8080/TCP,8443/TCP        2m29s
eclipse-hono-service-device-registry-ext        LoadBalancer   10.97.217.173   127.0.0.1     28443:31443/TCP                   2m29s
eclipse-hono-service-device-registry-headless   ClusterIP      None            <none>        <none>                            2m30s
```

The listing above has been retrieved from a Minikube cluster that emulates a load balancer via the `minikube tunnel`
command (refer to the [Minikube docs](https://minikube.sigs.k8s.io/docs/handbook/accessing/#loadbalancer-access) for details).
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
curl -skIX GET https://$REGISTRY_IP:28443/v1/tenants/DEFAULT_TENANT
```

the output should look similar to

```
HTTP/1.1 200 OK
etag: 89d40d26-5956-4cc6-b978-b15fda5d1823
content-type: application/json; charset=utf-8
content-length: 445
```

## Uninstalling the Chart

To uninstall/delete the `eclipse-hono` release from the target namespace:

```bash
helm uninstall eclipse-hono -n hono
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Release Notes

### 2.6.3

* Recreate expired demo certificates.

### 2.6.2

* Use Hono 2.6.0 container images.

### 2.6.1

* Use Hono 2.5.1 container images.
* Update jaegertracing/all-in-one and opentelemetry-collector image versions.

### 2.6.0

* Use Hono 2.5.0 container images.
* Update bitnami/kafka chart to version 26.8.x which uses Kafka 3.6 in Kraft mode.
* Update to latest MongoDB chart version 13.x.
* Add a `useLegacyAmqpTraceContextFormat` configuration property, allowing usage of a more generic format
  for storing OpenTelemetry trace context information in messages exchanged with an AMQP messaging network.

### 2.5.6

* Update bitnami/kafka chart to version 21.x which uses Kafka 3.4.
* Fix creation of example tenant and devices when Device Registry is configured to expose secure ports only.

### 2.5.5

* Add service account for protocol-adapter pods. Needed to query the container id via the K8s API, as it is
  done in upcoming Hono releases in case cgroups v2 is used.
* Update jaegertracing/all-in-one and opentelemetry-collector image versions.

### 2.5.4

* Fix Grafana dashboard being empty in case a release name is used that doesn't contain 'hono'.
* Use Bitnami OCI packages in Hono chart dependencies.
* Support using Chart/Release value references in 'deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.host'.
* Fix some links, apply README corrections.

### 2.5.3

* Allow configuring pod affinities.

### 2.5.2

* Allow setting the priorityClass for all pods to have more control over kubernetes scheduling.

### 2.5.1

* Allow customizing the PVC storage size for the Device Registry service.

### 2.5.0

* Allow customizing the pod/service names irrespective of .Release.Name.

### 2.4.4

* Pin MongoDB chart version to 13.16.x to fix incompatibilities with the used Kafka chart version.

### 2.4.3

* Use Hono 2.4.0 container images.

### 2.4.2

* Recreate expired demo certificates.

### 2.4.1

* Add the ability to use secrets to load environment variables.

### 2.4.0

* Do not expose insecure service port if insecure port is disabled for a component.
  Support disabling the insecure port of the Dispatch Router of the AMQP 1.0 based
  example messaging infrastructure.

### 2.3.2

* Fix using custom host with amqp Messaging Network Example.

### 2.3.1

* Update to Grafana Dashboard to work with the new metrics.

### 2.3.0

* Use Hono 2.3.0 container images.

### 2.2.1

* Update to Kafka chart version 20.x (using Kafka 3.3.x).
* Update to MongoDB chart version 13.x (using Mongo DB 6.x).
* Limit Kafka and Zookeeper JVM's memory consumption.

### 2.2.0

* Use Hono 2.2.0 container images.

### 2.1.5

* Use Hono 2.1.1 container images.

### 2.1.3

* Allow adding labels and annotations to pods by using *pod.labels* and *pod.annotations* properties per component.

### 2.1.2

* The Jaeger 'all-in-one' container, deployed if *jaegerBackendExample.enabled: true* is set, now supports collecting
  traces in the OpenTelemetry (OTLP) format.

### 2.1.0

* Upgraded app version to Hono 2.1.0.
* The Device Registry and the Command Router components are no longer explicitly configured with the Auth server's certificate for
  validating tokens but instead download the required public key(s) from the Auth server during runtime via its JWK resource.

### 2.0.6

* Upgraded app version to Hono 2.0.1.

### 2.0.5

* Instructions for setting up an Azure Kubernetes Service instance and installing Hono to it have been added.
  **NOTE**: The instructions have been moved here from the Hono code base *as-is* without review, i.e. the instructions
  might be outdated and no longer work with the current version of AKS.

### 2.0.4

* *livenessProbeInitialDelaySeconds* and *readinessProbeInitialDelaySeconds* have been deprecated due to the introduction of the
  *probes* parameter which allows you to configure the HTTP GET probes more specifically instead of just the initialDelaySeconds. The
  *probes* parameter is configurable globally but can be overwritten per component.

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
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set jaegerBackendExample.enabled=true
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

Note that *custom-http-secret* and *custom-http-secret* are expected to already exist in the namespace
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
[configured](https://eclipse.dev/hono/docs/admin-guide/amqp-network-config/#configuring-tenants-to-use-amqp-10-based-messaging)
separately to use either Kafka _or_ AMQP for messaging.

The following command provides a quick start for AMQP 1.0 based messaging (ensure `minikube tunnel` is running when using
Minikube):

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set messagingNetworkTypes[0]=amqp --set kafkaMessagingClusterExample.enabled=false --set amqpMessagingNetworkExample.enabled=true
```

The parameters enable the deployment of a simple AMQP 1.0 based messaging infrastructure, disable the deployment of the Kafka
broker and configure adapters and services to use AMQP 1.0 based messaging.

To use the service type `NodePort` instead of `LoadBalancer`, the following parameters must be added:
`--set useLoadBalancer=false --set kafka.externalAccess.broker.service.type=NodePort --set kafka.externalAccess.controller.service.type=NodePort`.

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

Note that *my-secret* is expected to already exist in the namespace that Hono gets installed to, i.e. the Helm chart
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

The chart can be customized to use container images other than the default ones. This can be used to install an older
version of the images or to install a Hono milestone using the chart. It can also be used to install custom built
images that need to be pulled from a different (private) container registry. Please refer to Hono's
[build instructions](https://www.eclipse.org/hono/docs/dev-guide/building_hono/#pushing-images) for details regarding
building custom images and pushing them to a private container registry.

The `values.yaml` file contains configuration properties for setting the container image and tag names to use for
Hono's components. The easiest way to override the version of all Hono components in one go is to set the
`honoImagesTag` and/or `honoContainerRegistry` properties to the desired values during installation.

The following command installs Hono using custom built images published on a private registry with tag
*2.0.0-custom* instead of the ones indicated by the chart's *appVersion* property:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set honoImagesTag=2.0.0-custom --set honoContainerRegistry=my-registry:9090
```

It is also possible to define the image and tag names and container registry for each component separately.
The easiest way to do that is to create a YAML file that specifies the particular properties:

```yaml
# pull standard adapter images in version 2.0.0 from Docker Hub by default
honoImagesTag: "2.0.0"

deviceRegistryExample:
  # pull custom Device Registry image from private container registry
  imageName: "my-hono/hono-service-device-registry-custom"
  imageTag: "1.0.0"
  containerRegistry: "my-private-registry.io"

authServer:
  # pull "older" release from Docker Hub
  imageName: "eclipse/hono-service-auth"
  imageTag: "1.12.2"
```

Assuming that the file is named `customImages.yaml`, the values can then be passed in to the
Helm `install` command as follows:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait -f /path/to/customImages.yaml
```

## Using custom built Container Images

The chart by default installs Hono's official container images. In some cases it might be desirable to build Hono
from source, e.g. in order to use a different metrics back end.

The container images created as part of the build process need to be made available to the Kubernetes cluster that
Hono should be installed to. This usually requires the images to be pushed to a (private) container registry that
the cluster can pull them from. Please refer to the documentation of the employed Kubernetes service provider for
details regarding the setup and configuration of a private container registry.

### Deploying via a private Registry

Please refer to Hono's [Building from Source](https://www.eclipse.org/hono/docs/dev-guide/building_hono/) instructions
for details regarding getting the source code, building and pushing the container images.

As in the previous section, the names of the custom images are configured in a YAML file:

```yaml
# use version 2.0.0-CUSTOM
honoImagesTag: "2.0.0-CUSTOM"

deviceRegistryExample:
  imageName: "my.registry.io/eclipse/hono-service-device-registry-mongodb"
authServer:
  imageName: "my.registry.io/eclipse/hono-service-auth"
commandRouterService:
  imageName: "my.registry.io/eclipse/hono-service-command-router-infinispan"
adapters:
  amqp:
    imageName: "my.registry.io/eclipse/hono-adapter-amqp"
  mqtt:
    imageName: "my.registry.io/eclipse/hono-adapter-mqtt"
  http:
    imageName: "my.registry.io/eclipse/hono-adapter-http"
```

Assuming that the file is named `customImages.yaml`, the values can then be passed in to the
Helm `install` command as follows:

```bash
helm install eclipse-hono eclipse-iot/hono -n hono --wait -f /path/to/customImages.yaml
```

### Deploying to Minikube

When using Minikube as the deployment target, things are a little easier. Minikube comes with an
embedded Docker daemon which can be used to build the container images instead of using a local
Docker daemon, thus eliminating the need to push the images to a registry altogether.
In order to use Minikube's Docker daemon, the following command needs to be run:

~~~sh
eval $(minikube docker-env)
~~~

This will set the Docker environment variables to point to Minikube's Docker daemon which can then be
used for building the container images and storing them locally in the Minikube VM.

In any case the build process can be started using the following command:

~~~sh
# in base directory of Hono working tree:
mvn clean install -Pbuild-docker-image,metrics-prometheus
~~~

To obtain the used Hono version and store it in an environment variable, use:

~~~sh
# in base directory of Hono working tree:
HONO_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
~~~

The newly built images can then be deployed using Helm:

~~~sh
helm install eclipse-hono eclipse-iot/hono -n hono --wait --set honoImagesTag=$HONO_VERSION
~~~

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

In order to make the native executables aware of the memory limits, the
[`-Xmx` GraalVM parameter](https://www.graalvm.org/22.0/reference-manual/native-image/MemoryManagement/#java-heap-size) can
be passed to the native executable as a command line parameter. This can be done by setting the `cmdLineArgs` property of the
component in the `values.yaml`. For example, the Authentication server can be configured to use the native executable based image
with 80% of the container's memory limit being available to the process like this:

```yaml
authServer:
  imageName: "eclipse/hono-service-auth-native"
  cmdLineArgs:
  - "-Xmx24m"
  resources:
    requests:
      cpu:
      memory: "30Mi"
    limits:
      cpu:
      memory: "30Mi"
```

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

## Using Microsoft Azure Kubernetes Service (AKS)

This section describes how to use Microsoft's
[Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/) (AKS) to create a managed Kubernetes
cluster and how to install Hono to it. The steps described include:

* Using [Azure Resource Manager (ARM)](https://docs.microsoft.com/azure/azure-resource-manager/) templates to
  automatically create infrastructure components on Azure.
* (Optionally) pushing Hono docker images to an [Azure Container Registry (ACR)](https://azure.microsoft.com/services/container-registry/).
* Helm based installation of Hono to the AKS instance.
* (Optionally) using a managed [Azure Service Bus](https://docs.microsoft.com/azure/service-bus-messaging) instance as the
  broker component for Hono's
  [AMQP 1.0 based messaging infrastructure](https://www.eclipse.org/hono/docs/architecture/component-view/#amqp-10-based-messaging-infrastructure)
  instead of the Apache ActiveMQ Artemis instance that is installed by the chart by default.
- [Virtual Network (VNet) service endpoints](https://docs.microsoft.com/azure/virtual-network) ensure protected communication
  between AKS and Azure Service Bus.

**NOTE**
This deployment model is not meant for production use but rather for evaluation as well as demonstration purposes or as a
baseline to evolve a production grade [Application architecture](https://docs.microsoft.com/azure/architecture/guide/)
out of it which includes Hono.
The instructions provided in this section have been created in 2018 and may therefore be outdated!


### Prerequisites

* An [Azure subscription](https://azure.microsoft.com/get-started/).
* [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) to set up the infrastructure.
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [helm](https://helm.sh/docs/intro/install/)
  to install Hono into the AKS instance.

### Setup

As described [here](https://docs.microsoft.com/azure/aks/kubernetes-service-principal) we will create an explicit
service principal. Later we add roles to this principal to access the Azure Container Registry.

```bash
# Create service principal
service_principal=`az ad sp create-for-rbac --name http://honoServicePrincipal --skip-assignment --output tsv`
app_id_principal=`echo $service_principal | cut -f1 -d ' '`
password_principal=`echo $service_principal | cut -f4 -d ' '`
object_id_principal=`az ad sp show --id $app_id_principal --query objectId --output tsv`
```

Note: it might take a few seconds until the principal is available for the next steps.

Now we create the Azure Container Registry instance and provide read access to the service principal.

```bash
# Resource group where the ACR is deployed.
acr_resourcegroupname={YOUR_ACR_RG}
# Name of your ACR.
acr_registry_name={YOUR_ACR_NAME}
# Full name of the ACR.
acr_login_server=$acr_registry_name.azurecr.io

az acr create --resource-group $acr_resourcegroupname --name $acr_registry-name  --sku Basic
acr_id_access_registry=`az acr show --resource-group $acr_resourcegroupname --name $acr_registry_name --query "id" --output tsv`
az role assignment create --assignee $app_id_principal --scope $acr_id_access_registry --role Reader
```

With the next command we will use the provided Azure Resource Manager templates to setup the AKS cluster.
This might take a while.

```bash
resourcegroup_name=hono
az group create --name $resourcegroup_name --location "westeurope"
unique_solution_prefix=myprefix
cd infra/azure
az group deployment create --name HonoBasicInfrastructure --resource-group $resourcegroup_name --template-file arm/honoInfrastructureDeployment.json --parameters uniqueSolutionPrefix=$unique_solution_prefix servicePrincipalObjectId=$object_id_principal servicePrincipalClientId=$app_id_principal servicePrincipalClientSecret=$password_principal
```

Notes:

- add the following parameter in case you want to opt for the Azure Service Bus as broker in Hono's
  AMQP 1.0 based messaging infrastructure instead of deploying an Apache ActiveMQ Artemis instance into AKS: *serviceBus=true*
- add the *kubernetesVersion* parameter to define the k8s version to use for the AKS cluster, e.g. *kubernetesVersion=1.23*.
  Note that not all versions [might be supported](https://docs.microsoft.com/de-de/azure/aks/supported-kubernetes-versions?tabs=azure-cli#azure-portal-and-cli-versions)
  in your Azure region, though.

After the deployment is complete you can set your cluster in *kubectl*.

```bash
az aks get-credentials --resource-group $resourcegroup_name --name $aks_cluster_name
```

Next create retain storage for the device registry.

```bash
kubectl apply -f managed-premium-retain.yaml
```

Now Hono can be installed to the AKS cluster as described in the [next section](#installing-hono-to-aks).

### Monitoring

You can monitor your cluster using
[Azure Monitor for containers](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-overview).

Navigate to [https://portal.azure.com](https://portal.azure.com) -> your resource group -> your kubernetes cluster

On an overview tab you fill find information about your cluster (status, location, version, etc.). Also, here
you will find a *Monitor Containers* link. Navigate to *Monitor Containers* and explore metrics and the current status of
your Cluster, Nodes, Controllers and Containers.

### Cleaning up

Use the following command to delete all created resources once they are no longer needed:

```sh
az group delete --name $resourcegroup_name --yes --no-wait
```

### Installing Hono to AKS

First we build the docker images and push them into the Azure Container Registry (ACR). Note that when using a
custom image tag, the tag name needs to be specified on the command line when installing the chart using Helm as
described [above](#deploying-via-a-private-registry).

```bash
# Resource group where the ACR is deployed.
acr_resourcegroupname={YOUR_ACR_RG}
# Name of your ACR.
acr_registry_name={YOUR_ACR_NAME}
# Full name of the ACR.
acr_login_server=$acr_registry_name.azurecr.io
# Authenticate your docker daemon with the ACR.
az acr login --name $ACR_NAME
# Build images.
cd hono
mvn install -Pbuild-docker-image -Ddocker.registry=$acr_login_server
# Push images to ACR.
./push_hono_images.sh 1.0.0-SNAPSHOT $acr_login_server
```

Now we can retrieve settings from the deployment for the following steps:

```bash
# Resource group of the AKS deployment
resourcegroup_name=hono

aks_cluster_name=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.aksClusterName.value -o tsv`
http_ip_address=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.httpPublicIPAddress.value -o tsv`
amqp_ip_address=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.amqpPublicIPAddress.value -o tsv`
mqtt_ip_address=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.mqttPublicIPAddress.value -o tsv`
registry_ip_address=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.registryPublicIPAddress.value -o tsv`
network_ip_address=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.networkPublicIPAddress.value -o tsv`
```

Note: add the following lines in case you opted for the Azure Service Bus variant:

```bash
service_bus_namespace=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.serviceBusNamespaceName.value -o tsv`
service_bus_key_name=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.serviceBusKeyName.value -o tsv`
service_bus_key=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.serviceBusKey.value -o tsv`
```

Finally install Hono. Leveraging the *managed-premium-retain* storage in combination with
*deviceRegistry.resetFiles=false* parameter is optional but ensures that Device registry storage will retain future
update deployments.

```bash
# in Hono working tree directory: hono/deploy
helm install eclipse-hono eclipse-iot/hono -n hono --wait \
    --set adapters.mqtt.svc.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$resourcegroup_name \
    --set adapters.http.svc.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$resourcegroup_name \
    --set adapters.amqp.svc.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$resourcegroup_name \
    --set deviceRegistryExample.svc.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$resourcegroup_name \
    --set amqpMessagingNetworkExample.dispatchRouter.svc.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$resourcegroup_name \
    --set deviceRegistryExample.storageClass=managed-premium-retain \
    --set deviceRegistryExample.resetFiles=false \
    --set adapters.mqtt.svc.loadBalancerIP=$mqtt_ip_address \
    --set adapters.http.svc.loadBalancerIP=$http_ip_address \
    --set adapters.amqp.svc.loadBalancerIP=$amqp_ip_address \
    --set deviceRegistryExample.svc.loadBalancerIP=$registry_ip_address \
    --set amqpMessagingNetworkExample.dispatchRouter.svc.loadBalancerIP=$network_ip_address
```

Note: add the following lines in case you opted for the Azure Service Bus variant:

```bash
    # Router update required to work together with Azure Service Bus
    --set amqpMessagingNetworkExample.broker.servicebus.host=$service_bus_namespace.servicebus.windows.net \
    --set amqpMessagingNetworkExample.broker.saslUsername=$service_bus_key_name \
    --set amqpMessagingNetworkExample.broker.saslPassword=$service_bus_key
```

Have fun with Hono on Microsoft Azure!

Next steps:

You can follow the steps as described in the [Getting Started]({{% homelink "getting-started/" %}}) guide with the
following differences:

Compared to a plain k8s deployment Azure provides us DNS names with static IPs for the Hono endpoints. To retrieve them:

```bash
HTTP_ADAPTER_IP=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.httpPublicIPFQDN.value -o tsv`
AMQP_ADAPTER_IP=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.amqpPublicIPFQDN.value -o tsv`
MQTT_ADAPTER_IP=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.mqttPublicIPFQDN.value -o tsv`
REGISTRY_IP=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.registryPublicIPFQDN.value -o tsv`
AMQP_NETWORK_IP=`az group deployment show --name HonoBasicInfrastructure --resource-group $resourcegroup_name --query properties.outputs.networkPublicIPFQDN.value -o tsv`
```

As Azure Service Bus does not support auto creation of queues you have to create a queue per tenant (ID), e.g. after
you have created your tenant run:

```bash
az servicebus queue create --resource-group $resourcegroup_name \
    --namespace-name $service_bus_namespace \
    --name $MY_TENANT
```
