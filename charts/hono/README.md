# Eclipse Hono

## Introduction

[Eclipse Hono™](https://www.eclipse.org/hono/) provides remote service interfaces for connecting large
numbers of IoT devices to a back end and interacting with them in a uniform way regardless of the device
communication protocol.

## Prerequisites

* Has been tested on Kubernetes 1.11+

## Installing the Chart

To install the chart with the release name `eclipse-hono`, run the following command (tested with Helm v3):

```bash
helm repo add eclipse-iot https://eclipse.org/packages/charts
helm repo update
helm install eclipse-hono eclipse-iot/hono
```

## Uninstalling the Chart

To uninstall/delete the `eclipse-hono` release:

```bash
helm delete eclipse-hono
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

**Tip**: To completely remove the release, run `helm delete --purge eclipse-hono`

## Configuration

The `values.yaml` file contains all possible configuration values along with documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install eclipse-hono eclipse-iot/hono --set useLoadBalancer=false
```

Alternatively, a YAML file that contains the values for the parameters can be provided when installing the chart:

```bash
helm install eclipse-hono eclipse-iot/hono -f /my/path/to/config.yaml
```

## Configuration Examples

### No Prometheus & Grafana

```yaml
prometheus:
  createInstance: false

grafana:
  enabled: false
```

### Jaeger Tracing

The `profileJaegerBackend.yaml` file contains configuration properties for installing
a Jaeger tracing back that collects tracing spans from Hono's components.
