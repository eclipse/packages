# Hawkbit Update Server

## Introduction

[Eclipse hawkBit™](https://www.eclipse.org/hawkbit/) is a domain independent back-end framework for rolling out software updates to constrained edge devices as well as more powerful controllers and gateways connected to IP based networking infrastructure.

This chart uses hawkbit/hawkbit-update-server container to run Hawkbit update server inside Kubernetes.

## Prerequisites

- Has been tested on Kubernetes 1.11+

## Installing the Chart

To install the chart with the release name `eclipse-hawkbit`, run the following command:

```bash
helm repo add eclipse-iot https://eclipse.org/packages/charts
helm repo update
helm install eclipse-hawkbit eclipse-iot/hawkbit
```

## Uninstalling the Chart

To uninstall/delete the `eclipse-hawkbit` deployment:

```bash
helm delete eclipse-hawkbit
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

> **Tip**: To completely remove the release, run `helm delete --purge eclipse-hawkbit`

## Configuration

Please view the `values.yaml` for the list of possible configuration values with its documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install eclipse-hawkbit eclipse-iot/hawkbit --set podDisruptionBudget.enabled=true
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.
