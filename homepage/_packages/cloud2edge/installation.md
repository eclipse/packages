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

## Run the installation

The Cloud2Edge package consists of multiple components. In order to keep them together and separate
from other components running in your Kubernetes cluster, it is feasible to install them into
their own name space. The following command creates the `cloud2edge` name space but you can select any
other name as well.

{% clipboard %}
kubectl create namespace cloud2edge
{% endclipboard %}

Next, install the package to the name space using Helm

{% clipboard %}
helm install -n cloud2edge c2e eclipse-iot/cloud2edge
{% endclipboard %}

and follow the instructions on screen regarding installation progress and next steps.

## Ready to run

Once the packages pods are all up and running, you can start using the package's services.
For an initial walk-through of the functionality [take a tour](../tour) of the Cloud2Edge package ...

{% endcapture %}

{% capture aside %}
{% include cluster-req.html reqs="Kubernetes=1.15.x;CPUs=4;Memory=8192 MiB;Disk=40 GiB" additional="Will require cluster admin privileges."%}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
