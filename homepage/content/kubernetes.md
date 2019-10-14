---
title: Pre-Requisites
lead: Getting you started with a common set of tools, used by all packages.
showToc: true
---

{{<row>}}

{{<col "12,md-8,lg-9">}}

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

### Minikube

[Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) is Kubernetes in a bottle.

Instead of provisioning a full blown cluster, it will create a virtual machine on your local system, and
provision a small, single-node cluster inside of it. As it puts the operating system in a VM, Minikube itself
can run on all major operating systems, including Windows and Mac OS.

Instead of duplicating the effort, documenting how to get Minikube up an running, we leave this to the
excellent [documentation of Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) itself.

#### Getting started

Once you have everything installed, you should be able to start a new cluster by executing:

    minikube start

And you can switch `kubectl` to the context `minikube`, and interact with your cluster:

    kubectl config use-context minikube

For example, get the current version of the client and server:

    kubectl version

Which should print out something like:

    Client Version: version.Info{Major:"1", Minor:"11+", GitVersion:"v1.11.0+d4cacc0", GitCommit:"d4cacc0", GitTreeState:"clean", BuildDate:"2018-10-10T16:38:01Z", GoVersion:"go1.10.3", Compiler:"gc", Platform:"linux/amd64"}
    Server Version: version.Info{Major:"1", Minor:"13+", GitVersion:"v1.13.4+c2a5caf", GitCommit:"c2a5caf", GitTreeState:"clean", BuildDate:"2019-09-21T02:12:52Z", GoVersion:"go1.11.13", Compiler:"gc", Platform:"linux/amd64"}

#### Starting and stopping

When you no longer need your cluster, you can stop it using:

    minishift stop
    # and later on
    minishift start

Or delete it using:

    minishift delete

#### Resources

Packages might need more resources than the default settings of Minikube allow. Packages are
encouraged to give you an estimate of what resources they require, you can translate this
into arguments to the `start` command:

    minishift start --cpus <cpus> --disk-size <size> --memory <memory>

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

</dl>

{{</col>}}

{{<col "12,md-4,lg-3" "d-none d-md-block">}}
<div class="position-sticky" style="top: 4rem;">
{{<toc>}}
</div>
{{</col>}}

{{</row>}}
