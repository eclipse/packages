---
title: 'Cloud'
layout: package-page
twitterTitle: Telemetry end-to-end | Cloud
description: Installations instructions for the Telemetry end-to-end package.
---

{% capture main %}

You will need a Kubernetes instance, the `kubectl` and the `helm` tool in order to deploy this package.
You will also need to add the Helm chart repository `eclipse-iot` to your local setup. Please refer to
our [pre-requisites]({{ "/prereqs" | relative_url }}) page for details.

You might also want to [install the Drogue IoT command line tool](https://github.com/drogue-iot/drg#installation) named `drg`. 

While technically any Kubernetes cluster will do, this tutorial focuses on Minikube to keep things as simple
as possible. When using Kind or any other Kubernetes cluster, some commands might need to be tweaked a bit.

## Minikube

The following command starts up a Minikube cluster suitable for this package:

    minikube start --cpus 4 --memory 8192 --disk-size 20gb --addons ingress

Be sure the run the load balancer tunnel, once the instance is started:

    minikube tunnel # do not abort this command or close the terminal it is running in

## Check access

Be sure that you are logged in to your Kubernetes cluster:

{% clipboard %}
kubectl version
{% endclipboard %}

This should print out the version of the client, but must also print out the version of the server.

{% details Example output %}
    Client Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.2", GitCommit:"8b5a19147530eaac9476b0ab82980b4088bbc1b2", GitTreeState:"clean", BuildDate:"2021-09-15T21:38:50Z", GoVersion:"go1.16.8", Compiler:"gc", Platform:"linux/amd64"}
    Server Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.2", GitCommit:"8b5a19147530eaac9476b0ab82980b4088bbc1b2", GitTreeState:"clean", BuildDate:"2021-09-15T21:32:41Z", GoVersion:"go1.16.8", Compiler:"gc", Platform:"linux/amd64"}
{% enddetails %}

## Install the package

This package consists of multiple components. Some of them are installed in the Kubernetes cluster, while the
IoT gateway and the device firmware are naturally installed in dedicated devices.

This page describes the installation of the cluster components, which is orchestrated using an overarching Helm
chart.

Assuming you are using Minikube, or have full cluster access, you can simply install this be running the following
Helm command:

{% clipboard %}
DOMAIN=.$(minikube ip).nip.io
helm upgrade --install eclipse-iot-telemetry eclipse-iot/telemetry-e2e \
  --timeout 30m \
  --set global.domain=$DOMAIN
{% endclipboard %}

{% alert warning: Ingress validation error %}

It may be that the deployment fails due to some "ingress" validation error. This is a know issue in the
NGINX ingress controllers (see <a class="alert-link" href="https://github.com/kubernetes/ingress-nginx/issues/6245" target="_blank">#6245</a>). Unfortunately,
there is currently no proper fix for this.

<hr/>

<p>However, a workaround exists. You can delete the validation webhook causing the issue:</p>
{% clipboard %}
kubectl delete validatingwebhookconfigurations ingress-nginx-admission
{% endclipboard %}

<p class="mb-0">After that, re-run the <code>helm upgrade</code> command above.</p>

{% endalert %}

## Be patient

Depending on your internet speed and overall I/O and CPU performance, this installation may take a bit. Normally it
will finish in around 15 minutes.

Assuming you have the `watch` command, you can watch the progress using the following command:

{% clipboard %}
watch kubectl get pods
{% endclipboard %}

## Once it is ready

Once the installation is ready, the Helm command will print out some details on the installation.

This will also give you the URL to the web console and the command as well as the access credentials.

## What is next?

Go to the next page and set up the IoT gateway.

{% endcapture %}

{% capture aside %}
{% include cluster-req.html reqs="Kubernetes=1.19.x;CPUs=4;Memory=8192 MiB;Disk=20 GiB" additional="<p>Will require cluster admin privileges and an active Ingress controller.</p> <p>You will also need a micro:bit&nbsp;v2 and a Raspberry&nbsp;Pi&nbsp;3+ to get the most out of this package.</p>"%}

<p>

{% include toc.html sticky=true %}

</p>

{% endcapture %}

{% include side-page.html main=main aside=aside %}
