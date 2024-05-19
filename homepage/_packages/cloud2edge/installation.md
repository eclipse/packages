---
title: 'Installation'
layout: package-page
twitterTitle: Cloud2Edge | Installation
description: Installations instructions for the Cloud2Edge package.
---

{% capture main %}

You will need a Kubernetes instance, the `kubectl` and the `helm` tool in order to deploy this package.
Please refer to our [pre-requisites]({{ "/prereqs" | relative_url }}) page for details.
Any Kubernetes compatible cluster will do, as long as it meets the requirements.

## Check access

Be sure that you are logged in to your Kubernetes cluster:

{% clipboard %}
kubectl version
{% endclipboard %}

This should print out the version of the client, but must also print out the version of the server.

{% details Example output %}
    Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.1", GitCommit:"d647ddbd755faf07169599a625faf302ffc34458", GitTreeState:"clean", BuildDate:"2019-10-02T17:01:15Z", GoVersion:"go1.12.10", Compiler:"gc", Platform:"linux/amd64"}
    Server Version: version.Info{Major:"1", Minor:"13+", GitVersion:"v1.13.4+c2a5caf", GitCommit:"c2a5caf", GitTreeState:"clean", BuildDate:"2019-09-21T02:12:52Z", GoVersion:"go1.11.13", Compiler:"gc", Platform:"linux/amd64"}
{% enddetails %}

## Install the package

The Cloud2Edge package consists of multiple components. In order to keep them together and separate
from other components running in your Kubernetes cluster, it is feasible to install them into
their own namespace. The following command creates the `cloud2edge` namespace, but you can select any
other name as well.

{% clipboard %}
NS=cloud2edge
kubectl create namespace $NS
{% endclipboard %}

Next, install the package to the namespace using Helm.

{% variants %}

{% variant NodePort %}
For a single-node Kubernetes cluster, the most basic and universally supported way to direct traffic to the
Kubernetes services is done via *NodePorts*.

To install the Cloud2Edge package using NodePort services, run the following command:

{% clipboard %}
RELEASE=c2e
helm install -n $NS --wait --timeout 20m $RELEASE eclipse-iot/cloud2edge
{% endclipboard %}
{% endvariant %}

{% variant LoadBalancer %}
Managed Kubernetes variants usually support exposing service endpoints via load balancers on public
IP addresses. On a local Kubernetes cluster, load balancer support requires additional preparation
(e.g. running [minikube tunnel](https://minikube.sigs.k8s.io/docs/handbook/accessing/#loadbalancer-access) on Minikube, 
or setting up [MetalLB](https://metallb.universe.tf/) on [Kind](https://kind.sigs.k8s.io/docs/user/loadbalancer/) or [MicroK8s](https://microk8s.io/docs/addon-metallb)).

To install the Cloud2Edge package using load balancers, run the following command:

{% clipboard %}
RELEASE=c2e
helm install -n $NS --wait --timeout 20m --set hono.useLoadBalancer=true \
 --set hono.kafka.externalAccess.broker.service.type=NodePort \
 --set hono.kafka.externalAccess.controller.service.type=NodePort \
 --set ditto.nginx.service.type=LoadBalancer $RELEASE eclipse-iot/cloud2edge
{% endclipboard %}
{% endvariant %}

{% endvariants %}

## Ready to run

Once the package's pods are all up and running, you can start using its services.
The easiest way of getting to know the Cloud2Edge package is by [taking a little tour](../tour).

{% endcapture %}

{% capture aside %}
{% include cluster-req.html reqs="Kubernetes=1.19.x;CPUs=4;Memory=8192 MiB;Disk=40 GiB" additional="Will require cluster admin privileges."%}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
