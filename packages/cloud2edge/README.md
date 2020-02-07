# Eclipse Cloud2Edge

The Eclipse IoT Cloud2Edge (C2E) package is an integrated suite of services developers can use to build
IoT applications that are deployed from the cloud to the edge.

The package currently consists of

* Eclipse Hono
* Eclipse Ditto

The package is supposed to provide an easy way for developers to start using Eclipse Hono and Ditto in their
IoT application.

## Installing the Chart

To install the chart with the release name `c2e`, run the following command (tested with Helm v3):

```bash
helm repo add eclipse-iot https://eclipse.org/packages/charts
helm repo update
helm install c2e eclipse-iot/cloud2edge
```

## Uninstalling the Chart

To uninstall/delete the `c2e` release:

```bash
helm delete c2e
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Please view the `values.yaml` for the list of possible configuration values with its documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install c2e eclipse-iot/cloud2edge --set hono.useLoadBalancer=true
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.
