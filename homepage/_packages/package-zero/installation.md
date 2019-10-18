---
title: 'Installation'
layout: package-page
---

{% capture main %}

You will need a Kubernetes instance in order to deploy this package. If you haven't done so already, take a look at our [Kubernetes installation]({{ "/prereqs" | relative_url }}) page. Any Kubernetes compatible cluster will do, as long as
it meets the requirements.

## Check access

Be sure that you are logged in into your Kubernetes cluster:

{% clipboard %}
kubectl version
{% endclipboard %}

This should print out the version of the client, but must also print out the version of the server.

{% details Example output %}
    Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.1", GitCommit:"d647ddbd755faf07169599a625faf302ffc34458", GitTreeState:"clean", BuildDate:"2019-10-02T17:01:15Z", GoVersion:"go1.12.10", Compiler:"gc", Platform:"linux/amd64"}
    Server Version: version.Info{Major:"1", Minor:"13+", GitVersion:"v1.13.4+c2a5caf", GitCommit:"c2a5caf", GitTreeState:"clean", BuildDate:"2019-09-21T02:12:52Z", GoVersion:"go1.11.13", Compiler:"gc", Platform:"linux/amd64"}
{% enddetails %}

## Clone repository

Clone the repository with the deployment scripts:

{% clipboard %}
git clone https://github.com/eclipse/packages.git
cd packages
{% endclipboard %}

Change into the directory of this package:

{% clipboard %}
cd packages/package-zero
{% endclipboard %}

All further commands assume that you are operating from this directory.

## Run the deployment

First create a new namespace for the deployment:

{% clipboard %}
kubectl create namespace package-zero
{% endclipboard %}

Next, render the Helm charts:

{% clipboard %}
mkdir output
helm template . --name package-zero --namespace package-zero --output-dir output
{% endclipboard %}

The output is in the directory `output`. It is not yet deployed, but you
can inspect it and then apply it by running:

{% clipboard %}
kubectl apply -Rf output/
{% endclipboard %}

## Monitor deployment

When you execute the following command:

{% clipboard %}
kubectl get pods
{% endclipboard %}

You should see the pods being started and becoming ready.

{% details Example of started pods %}
    NAME                                               READY   STATUS    RESTARTS   AGE
    package-zero-adapter-amqp-vertx-57dc849d4c-tw25z   1/1     Running   0          148m
    package-zero-adapter-http-vertx-6bdffc59-t54h5     1/1     Running   0          148m
    package-zero-adapter-mqtt-vertx-74cdb9644b-6pgs6   1/1     Running   0          148m
    package-zero-artemis-54ffcff88f-7w85x              1/1     Running   0          148m
    package-zero-dispatch-router-54d968954b-vrp7z      1/1     Running   0          148m
    package-zero-service-auth-6c9bcf8899-qmztm         1/1     Running   0          148m
    package-zero-service-device-registry-0             1/1     Running   0          148m
{% enddetails %}

## Ready to run

Once the pods are all ready, you are ready to use the deployment. For an initial walk-through of the functionality
see the section [Take a tour](../tour).

{% endcapture %}

{% capture aside %}
{% include cluster-req.html reqs="Kubernetes=1.15.x;CPUs=4;Memory=8192 MiB;Disk=40 GiB" additional="Will require cluster admin privileges."%}
{% endcapture %}

{% include side-page.html main=main aside=aside %}
