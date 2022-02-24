# Eclipse Ditto

## Introduction

[Eclipse Ditto™](https://www.eclipse.org/ditto/) is a technology in the IoT implementing a software pattern 
called “digital twins”. A digital twin is a virtual, cloud based, representation of his real world counterpart 
(real world “Things”, e.g. devices like sensors, smart heating, connected cars, smart grids, EV charging stations, …).

This chart uses `eclipse/ditto-XXX` containers to run Ditto inside Kubernetes.

## Prerequisites

Installing Ditto using the chart requires the Helm tool to be installed as described on the 
[IoT Packages chart repository prerequisites](https://www.eclipse.org/packages/prereqs/) page.

TL;DR:

* have a correctly configured [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl) (either against a local or remote k8s cluster)
* have [Helm installed](https://helm.sh/docs/intro/)
* add the Eclipse IoT Packages Helm repo:
    ```bash
    helm repo add eclipse-iot https://eclipse.org/packages/charts
    helm repo update
    ```

The Helm chart is being tested to successfully install on the five most recent Kubernetes versions.

## Installing the Chart

The instructions below illustrate how Ditto can be installed to the `ditto` name space in a Kubernetes cluster using 
release name `eclipse-ditto`.  
The commands can easily be adapted to use a different name space or release name.

The target name space in Kubernetes only needs to be created if it doesn't exist yet:

```bash
kubectl create namespace ditto
```

The chart can then be installed to name space `ditto` using release name `eclipse-ditto`:

```bash
helm install --dependency-update -n ditto eclipse-ditto eclipse-iot/ditto
```


## Uninstalling the Chart

To uninstall/delete the `eclipse-ditto` release:

```bash
helm delete -n ditto eclipse-ditto
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

> **Tip**: To completely remove the release, run `helm delete -n ditto --purge eclipse-ditto`

## Configuration

Please view the `values.yaml` for the list of possible configuration values with its documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install -n ditto eclipse-ditto eclipse-iot/ditto --set swaggerui.enabled=false
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Configuration Examples

### OpenID Connect (OIDC)

To enable OIDC authentication adjust following properties:

```yaml
global:
  jwtOnly: true

gateway:
  enablePreAuthentication: false
  systemProps:
    - "-Dditto.gateway.authentication.oauth.openid-connect-issuers.myprovider.issuer=openid-connect.onelogin.com/oidc"
```

### Securing Devops Resource

To secure /devops and /status resource adjust configuration to (username will be `devops`):

```yaml
gateway:
  devopsSecureStatus: true
  devopsPassword: foo
  statusPassword: bar
```


## Troubleshooting

If you experience high resource consumption (either CPU or RAM or both), you can limit the resource usage by
specifying resource limits.
This can be done individually for each single component.
Here is an example how to limit CPU to 0.25 Cores and RAM to 512 MiB for the `connectivity` service:

```bash
helm upgrade -n ditto eclipse-ditto . --install --set connectivity.resources.limits.cpu=0.25 --set connectivity.resources.limits.memory=512Mi
```
