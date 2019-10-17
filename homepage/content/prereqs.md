---
title: Pre-Requisites
lead: Getting you started with a common set of tools, used by all packages.
showToc: true
---

{{<content>}}

{{<content/main>}}

## Kubernetes Client

First of all, you will need a command tool named `kubectl`. This application allows you to interact with
your Kubernetes cluster from the command line. While Kubernetes also comes with a Web UI, it is much simpler
to document the installation procedures using command line tool. Also does the Web UI change over time, and
with different Kubernetes variants. However the `kubectl` tool works with all variations of Kubernetes, as it
uses the standardized API in the background.

You can find more information in the Kubernetes documentation: [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Kubernetes Cluster

For the cloud side environment, you will need an installation of Kubernetes. Kubernetes comes in
different forms, and we try to document a few of them for you. There are other variants as well,
and you are welcome to try all of them. All packages should be able to run on any Kubernetes
you provide.

Packages are encouraged to give you an estimate of what resources they require. The following is
an example of what this may look like. You will need to translate this into the specific
Kubernetes environment you have. Also may the package declare on which Kubernetes platform
it was tested. This doesn't mean that other Kubernetes versions don't work, but sets some
expectations of what was tested at some point.

{{<row>}}

{{<col "12,sm-6,md-5,lg-4" "mx-md-auto mb-3">}}
{{<cluster-req "Kubernetes=1.15.x" "CPUs=+2" "Memory=1024 MiB" "Disk=40 GiB" />}}
{{</col>}}

{{</row>}}

For each documentation Kubernetes environment on this page, you will
find a section that explains how to do this.

### Minikube

[Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) is Kubernetes in a bottle.

Instead of provisioning a full blown cluster, it will create a virtual machine on your local system, and
provision a small, single-node cluster inside of it. As it puts the operating system in a VM, Minikube itself
can run on all major operating systems, including Windows and Mac OS.

Instead of duplicating the effort, documenting how to get Minikube up an running, we leave this to the
excellent [documentation of Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) itself.

#### Getting started

Once you have everything installed, you should be able to start a new cluster by executing:

{{<clipboard>}}
    minikube start
{{</clipboard>}}

And you can switch `kubectl` to the context `minikube`, and interact with your cluster:

{{<clipboard>}}
    kubectl config use-context minikube
{{</clipboard>}}

For example, get the current version of the client and server:

{{<clipboard>}}
    kubectl version
{{</clipboard>}}

Which should show a proper version for the client **and** the server:

    Client Version: version.Info{Major:"1", Minor:"11+", GitVersion:"v1.11.0+d4cacc0", GitCommit:"d4cacc0", GitTreeState:"clean", BuildDate:"2018-10-10T16:38:01Z", GoVersion:"go1.10.3", Compiler:"gc", Platform:"linux/amd64"}
    Server Version: version.Info{Major:"1", Minor:"13+", GitVersion:"v1.13.4+c2a5caf", GitCommit:"c2a5caf", GitTreeState:"clean", BuildDate:"2019-09-21T02:12:52Z", GoVersion:"go1.11.13", Compiler:"gc", Platform:"linux/amd64"}

#### Starting and stopping

When you no longer need your cluster, you can stop it using:

{{<clipboard>}}
    minishift stop
{{</clipboard>}}

This will suspend the VM so that you can, later on, resume it by
executing:

{{<clipboard>}}
    minishift start
{{</clipboard>}}

Or delete it using:

{{<clipboard>}}
    minishift delete
{{</clipboard>}}

#### Resources

You can translate the package resources requirements into arguments for the `start` command like this:

    minishift start --cpus <cpus> --disk-size <size> --memory <memory> --kubernetes-version <version>

Using the following arguments:

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
The Kubernetes version deployed into the virtual machine (e.g. <code>--kubernetes-version v1.15.4</code>). 
</dd>

</dl>

## Helm

You will need an installation of Helm on the machine which is used to deploy the packages. You can find
installation instructions for Helm in the Helm documentation under [Installing Helm](https://helm.sh/docs/using_helm/#installing-helm).

You will not need to install Tiller on the cluster. Of course, if you prefer to use Tiller, you may still
do so. Also see: [FAQ: Why aren't you using Tiller]({{<relref "/faq/_index.md#why-aren-t-you-using-tiller">}}).

## Command line tools

Some tutorials might require some common command line tool. The installation depends on the
operating system you are using.

It is required to have the following tools installed:

### Bash

Bash is available on Windows, Linux and Mac OS X. True platform independence. So all commands which
you are supposed to execute can be executed in Bash, version 3 or newer.

### curl

For downloading files and execution API call the tool `curl` will be used.

### Mosquitto CLI

Mosquitto command line tools: e.g. `moquitto_pub`

{{</content/main>}}

{{<content/aside>}}
{{<toc sticky="true">}}
{{</content/aside>}}

{{</content>}}
