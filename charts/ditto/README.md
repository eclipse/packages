# Eclipse Ditto

## Introduction

[Eclipse Ditto™](https://www.eclipse.org/ditto/) is a technology in the IoT implementing a software pattern 
called “digital twins”. A digital twin is a virtual, cloud based, representation of his real world counterpart 
(real world “Things”, e.g. devices like sensors, smart heating, connected cars, smart grids, EV charging stations, …).

This chart uses `eclipse/ditto-XXX` containers to run Ditto inside Kubernetes.

## Prerequisites

* Has been tested on Kubernetes 1.11+

## Installing the Chart

To install the chart with the release name `eclipse-ditto`, run the following command (tested with Helm v3):

```bash
helm repo add eclipse-iot https://eclipse.org/packages/charts
helm repo update
helm install eclipse-ditto eclipse-iot/ditto
```

## Uninstalling the Chart

To uninstall/delete the `eclipse-ditto` release:

```bash
helm delete eclipse-ditto
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

> **Tip**: To completely remove the release, run `helm delete --purge eclipse-ditto`

## Configuration

Please view the `values.yaml` for the list of possible configuration values with its documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install eclipse-ditto eclipse-iot/ditto --set swaggerui.enabled=false
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Configuration Examples

### OpenID Connect (OIDC)

To enable OIDC authentication adjust following properties:

```yaml
global:
  jwtOnly: true

gateway:
  enableDummyAuth: false
  systemProps:
    - "-Dditto.gateway.authentication.oauth.openid-connect-issuers.myprovider=openid-connect.onelogin.com/oidc"
```

### Securing Devops Resource

To secure /devops and /status resource adjust configuration to (username will be `devops`):

```yaml
gateway:
  enableDummyAuth: false
  devopsSecureStatus: true
  devopsPassword: foo
  statusPassword: bar
```

## Local Setup

In order to install the Helm chart locally (e.g. in order to enhance the chart), follow the instructions in this section.

### Requirements

* [Kubernetes IN Docker](https://github.com/kubernetes-sigs/kind)
* [kubectl](https://kubernetes.io/docs/tasks/kubectl/install/)
* [Helm v3](https://docs.helm.sh/using_helm/#installing-helm)

### Run Eclipse Ditto

#### Start KIND Cluster

Prepare a kind configuration file named `kind-config.yaml`, with following content:

```yaml
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
# the control plane node config
- role: control-plane
# Worker reachable from local machine
- role: worker
  extraPortMappings:
  # HTTP
  - containerPort: 32080
    hostPort: 80
```

Start kind cluster

```bash
kind create cluster --image "kindest/node:v1.14.9" --config kind-config.yaml
```

#### Install Eclipse Ditto

**Note:** Following commands requires Helm v3

Install ditto chart with default configuration

```bash
helm upgrade eclipse-ditto . --install
```

Follow the instructions from `NOTES.txt` (printed when install is finished).

#### Delete Eclipse Ditto Release

```bash
helm delete eclipse-ditto
```

#### Destroy KIND Cluster

```bash
kind delete cluster
```

### Troubleshooting

If you experience high resource consumption (either CPU or RAM or both), you can limit the resource usage by
specifying resource limits.
This can be done individually for each single component.
Here is an example how to limit CPU to 0.25 Cores and RAM to 512 MiB for the `connectivity` service:

```bash
helm upgrade eclipse-ditto . --install --set connectivity.resources.limits.cpu=0.25 --set connectivity.resources.limits.memory=512Mi
```
