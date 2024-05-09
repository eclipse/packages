---
title: Pre-Requisites
lead: Getting you started with a common set of tools, used by all packages.
layout: page
---

{%capture main%}
## Kubernetes Client

First, you will need a command tool named `kubectl`. This application allows you to interact with
your Kubernetes cluster from the command line. While Kubernetes also comes with a Web UI, it is much simpler
to document the installation procedures using command line tool. Also does the Web UI change over time, and
with different Kubernetes variants. However, the `kubectl` tool works with all variations of Kubernetes, as it
uses the standardized API in the background.

You can find more information in the Kubernetes documentation: [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Kubernetes Cluster

For the cloud side environment, you will need an installation of Kubernetes. Kubernetes comes in
different forms, and we try to document a few of them for you. There are other variants as well,
and you are welcome to try all of them. All packages should be able to run on any Kubernetes
you provide.

Generally, you can either use a cloud provider, such as Azure (AKS) or AWS (EKS) to provide a Kubernetes cluster for you, or you can set up one by yourself.
[Here](https://landscape.cncf.io/card-mode?category=platform&grouping=category) you can find a list of Kubernetes options.
As the Kubernetes API is standardized both ways will work.
However, setting up Kubernetes yourself is not trivial and requires some more effort.
As part of this tutorial, we present two different K8s distributions (and how to deploy Eclipse IoT Packages with them),
namely [MicroK8s](#microk8s) and [Minikube](#minikube).

Packages are encouraged to give you an estimate of what resources they require. The following is
an example of what this may look like. You will need to translate this into the specific
Kubernetes environment you have. Also, the package may declare on which Kubernetes platform
it was tested. This doesn't mean that other Kubernetes versions don't work, but sets some
expectations of what was tested at some point.

<div class="row">

<div class="col-12 col-sm-6 col-md-5 col-lg-4 mx-md-auto mb-3">
{% include cluster-req.html reqs="Kubernetes=1.17.x;CPUs=2;Memory=1024 MiB;Disk=40 GiB" additional="Additional requirements."%}
</div>

</div>


### MicroK8s

[MicroK8s](https://microk8s.io/) is a Kubernetes distribution, maintained by Canonical, that enables developers to run a
fully-fledged Kubernetes cluster on their own infrastructure. In contrast to *minikube* it is not only intended for testing
purposes but also for production scenarios, e.g. in cases where a cloud setup is not possible or desirable.

All you need is a virtual or physical machine with root access and the [snap package manager](https://snapcraft.io/docs/installing-snapd).

Install MicroK8s, executing `sudo snap install microk8s --classic`

For Windows or macOS, or a Linux system without snap, consult the [alternative install methods for MicroK8s](https://microk8s.io/docs/install-alternatives). 
When installing on [Windows](https://microk8s.io/docs/install-windows) or using [Multipass](https://microk8s.io/docs/install-multipass), 
make sure the CPU, memory and disk configuration corresponds to what is required by the package.

After the installation, check the cluster status, by running `microk8s status --wait-ready`

Once the cluster is up and running you will need to enable a few modules that are required for installing an
Eclipse IoT Packages package such as Cloud2Edge.

```sh
LOCAL_ADDRESS=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
microk8s enable metrics-server
microk8s enable storage
microk8s enable dns
microk8s enable metallb:$LOCAL_ADDRESS-$LOCAL_ADDRESS
```

These commands enable
- the metrics server, which is helpful for further investigating your cluster usage
- the storage module, which enables persistent volumes
- the cluster dns server
- and the load balancing module, which enables external access to your cluster

In order to control the cluster using the Kubernetes CLI (`kubectl`) you can use the integrated `microk8s kubectl <command>` 
option which ships with MicroK8s.

In order to use the host's `kubectl` command, consult the [Working with kubectl](https://microk8s.io/docs/working-with-kubectl) documentation chapter.

In case you are installing MicroK8s on a remote machine that is accessible via a real domain name, you can follow the
[Authentication and authorization](https://microk8s.io/docs/services-and-ports#heading--auth) documentation section on how
to allow access via that domain name.

### Minikube

[Minikube](https://minikube.sigs.k8s.io/docs/) is Kubernetes in a bottle.

Instead of provisioning a full-blown cluster, it will create a Docker (or similarly compatible) container
or a virtual machine on your local system, and provision a small, single-node cluster inside it. 
Minikube can run on all major operating systems, including Windows and macOS.

Instead of duplicating the effort, documenting how to get Minikube up and running, we leave this to the
excellent [documentation of Minikube](https://minikube.sigs.k8s.io/docs/start/) itself.

#### Getting started

Once you have everything installed, you should be able to start a new cluster via `minikube start`, specifying the
resources you want to allocate for the cluster:

{%clipboard%}
minikube start --cpus &lt;cpus&gt; --disk-size &lt;size&gt; --memory &lt;memory&gt; --kubernetes-version &lt;version&gt;
{%endclipboard%}

You can translate the package resources requirements into these arguments:

<dl class="row">

<dt class="col-sm-2">cpus</dt>
<dd class="col-sm-10">The number of CPUs you allocate for Minikube (e.g. <code>--cpus 2</code>).</dd>

<dt class="col-sm-2">size</dt>
<dd class="col-sm-10">
The size of the disk available for the cluster and persistent volumes. In the format <code>&lt;number&gt;&lt;unit&gt;</code>,
where unit can be either <code>k</code>, <code>m</code>, or <code>g</code> (e.g. 20GiB means <code>--disk-size 20g</code>).
</dd>

<dt class="col-sm-2">memory</dt>
<dd class="col-sm-10">
The amount of RAM allocated to the virtual machine. This is the amount in MiB (e.g. for 8GiB means <code>--memory 8192</code>.
</dd>

<dt class="col-sm-2">version</dt>
<dd class="col-sm-10">
The Kubernetes version deployed into the virtual machine (e.g. <code>--kubernetes-version v1.20.2</code>). 
</dd>

</dl>

After Minikube got started, you can switch `kubectl` to the context `minikube` and interact with your cluster:

{%clipboard%}
kubectl config use-context minikube
{%endclipboard%}

For example, get the current version of the client and server:

{%clipboard%}
kubectl version
{%endclipboard%}

Which should show a proper version for the client **and** the server:

```sh
Client Version: version.Info{Major:"1", Minor:"11+", GitVersion:"v1.11.0+d4cacc0", GitCommit:"d4cacc0", GitTreeState:"clean", BuildDate:"2018-10-10T16:38:01Z", GoVersion:"go1.10.3", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"13+", GitVersion:"v1.13.4+c2a5caf", GitCommit:"c2a5caf", GitTreeState:"clean", BuildDate:"2019-09-21T02:12:52Z", GoVersion:"go1.11.13", Compiler:"gc", Platform:"linux/amd64"}
```

#### Starting and stopping

When you no longer need your cluster, you can stop it using:

{%clipboard%}
minikube stop
{%endclipboard%}

This will suspend the VM so that you can, later on, resume it by
executing:

{%clipboard%}
minikube start
{%endclipboard%}

Or delete it using:

{%clipboard%}
minikube delete
{%endclipboard%}


#### Load Balancer Support

To enable support for load balancer services, run

{%clipboard%}
minikube tunnel
{%endclipboard%}

in a separate terminal (keeping it running) before installing a package.

#### Addons

Some packages may require additional addons, like the ingress addon for providing a default ingress controllers.

Such addons can be enabled when starting the Minikube instance, using the following flag:

```sh
minikube start ... --addons ingress
```

## Helm

You will need an installation of Helm on the machine which is used to deploy the packages. You can find
installation instructions for Helm in the Helm documentation under [Installing Helm](https://helm.sh/docs/intro/install/).

The required Helm version is 3.9 or later.

### Repository

The Eclipse IoT Packages project hosts a Helm chart repository for Eclipse IoT projects.
Adding the repository can be done on your local machine be executing:

{% clipboard %}
    helm repo add eclipse-iot https://eclipse.org/packages/charts
{% endclipboard %} 

Read more: [Helm chart repository]({{"/repository" | relative_url }} "title").

## Command line tools

Some tutorials might require some common command line tool. The installation depends on the
operating system you are using.

It is required to have the following tools installed:

### Bash

Bash is available on Windows, Linux and Mac OS X. True platform independence. So all commands which
you are supposed to execute can be executed in Bash, version 3 or newer.

### curl

For downloading files and execution API calls the tool `curl` will be used.

### Mosquitto CLI

Mosquitto command line tools: e.g. `mosquitto_pub`

{%endcapture%}

{%capture aside%}
{%include toc.html sticky=true%}
{%endcapture%}

{%include side-page.html main=main aside=aside%}
