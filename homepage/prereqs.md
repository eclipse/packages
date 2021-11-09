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
namely [MicroK8s](microk8s) and [Minikube](minikube).

Packages are encouraged to give you an estimate of what resources they require. The following is
an example of what this may look like. You will need to translate this into the specific
Kubernetes environment you have. Also may the package declare on which Kubernetes platform
it was tested. This doesn't mean that other Kubernetes versions don't work, but sets some
expectations of what was tested at some point.

<div class="row">

<div class="col-12 col-sm-6 col-md-5 col-lg-4 mx-md-auto mb-3">
{% include cluster-req.html reqs="Kubernetes=1.17.x;CPUs=2;Memory=1024 MiB;Disk=40 GiB" additional="Additional requirements."%}
</div>

</div>

For each documentation Kubernetes environment on this page, you will find a section that explains how to do this.

### MicroK8s

[MicroK8s](https://microk8s.io/) is a Kubernetes distribution, maintained by Canonical and enables developers to run a
fully-fledged Kubernetes cluster on their own infrastructure. In contrast to *minikube* it is not only intended for testing
purposes but also for production scenarios, e.g. in cases where a cloud setup is not possible or desirable.

All you need is a virtual or physical machine with root access and the [snap package manager](https://snapcraft.io/docs/installing-snapd).

Install MicroK8s, executing `sudo snap install microk8s --classic`

Check the cluster status, by running `microk8s status --wait-ready`

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

In order to control the cluster using the Kubernetes CLI (`kubectl`) you can either use integrated option which ships
with MicroK8s. Alternatively, e.g. if you want to control your cluster from another machine you can extract the cluster
config file and use it with a native install of `kubectl`.

#### Integrated option

Use `microk8s kubectl <command>`

#### Native option

Execute `microk8s kubectl config view --raw > $HOME/.kube/config`

Now, use `kubectl <command>`

In case you are not running the cluster on a your local machine you can also enable remote access by following these steps:
- stop your cluster by running `microk8s stop`
- edit the file `/var/snap/microk8s/current/certs/csr.conf.template` and add your domain/ip address:

```
DNS.6 = <domain_of_microk8s_host>
IP.7 = <public_ip_of_microk8s_host>
```
Restart your cluster by running `microk8s start` and extract the new Kubernetes configuration by executing
`microk8s kubectl config view --raw`.
Now copy the configuration description to your local machine under `~/.kube/config`.

#### Loadbalancing and Ingress

Once you have a Kubernetes cluster available and installed the Kubernetes and Helm CLI (see below), you are now ready
to setup an Eclipse IoT Packages deployment such as Cloud2Edge. By default the containers can communicate within the
cluster. But to access a container and its respective services from outside the cluster (e.g. from another machine)
you need to perform some extra steps.
Depending on your setup, you have 3 options available how to make your services externally available.

##### NodePort

The simplest way to expose your services is by using a Kubernetes Service with type
[NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport). The Cloud2Edge Helm chart uses
this option by default.
Using this in production mode has some drawbacks and is not recommended as it is very static, enables just one Service
per port and only allows you to use ports in the range 30000–32767.

##### LoadBalancer

Another option is the [LoadBalancer](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer)
Service type, which requires your Kubernetes provider to supply an external load balancing module. The provider is
also responsible for provisioning external IP addresses.
The Cloud2Edge enables this option by setting the flags `hono.useLoadBalancer` to `true` and `ditto.nginx.service.type`
to `LoadBalancer`.
The downside of this approach is that each of your Services requires its own publicly available IP address, which
might either not be desirable (due to higher costs) or possible at all e.g. in case you are running your deployment
on a custom Kubernetes setup (such as MicroK8s).

##### Ingress Loadbalancing

Ingress controllers employ a single LoadBalancer service, which then routes all incoming traffic to the actual
controller in charge of distributing it to the right endpoints.
This allows not only differentiating by port, but also routing by path (HTTP) or subdomain.
We are using the [Ambassador](https://www.getambassador.io/) controller, as it is capable of routing not only HTTP
ingress but also on the TCP level.

1. Deploy the Cloud2Edge Helm chart setting the aforementioned flags to **not** use the LoadBalancer type
2. Create a namespace for Ambassador: `kubectl create namespace ambassador`
3. Add the Helm repository: `helm repo add datawire https://www.getambassador.io`
4. Create a file named `override.yaml`, that contains all necessary Ambassador configurations:
   ```yaml
   enableAES: false
   image:
     repository: docker.io/datawire/ambassador
   replicaCount: 1
   service:
     ports:
       - name: mqtt-adapter
         port: 1883
         targetPort: 1883
       - name: http-adapter
         port: 18080
         targetPort: 18080
       - name: device-registry
         port: 28080
         targetPort: 28080
       - name: dispatch-router
         port: 5671
         targetPort: 15671
       - name: ditto
         port: 38080
         targetPort: 38080
   ```
5. Start Ambassador by running `helm install ambassador -n ambassador -f override.yaml datawire/ambassador`
6. Then we create the necessary mappings, such that the controller knows where to route incoming traffic.
   These mappings are specifically adjusted to the Cloud2Edge deployment, so you will have to create your own
   mappings for other packages. Create a new file named `ambassador-mappings.yaml` and replace the release name and
   the namespace of your deployment:
   ```yaml
   apiVersion: getambassador.io/v2
   kind:  TCPMapping
   metadata:
     name: ambassador-http-adapter
     namespace: ambassador
   spec:
     port: 18080
     service: {name-of-helm-release}-adapter-http-vertx.{kubernetes-namespace}:8080
   ---
   apiVersion: getambassador.io/v2
   kind:  TCPMapping
   metadata:
     name: ambassador-mqtt-adapter
     namespace: ambassador
   spec:
     port: 1883
     service: {name-of-helm-release}-adapter-mqtt-vertx.{kubernetes-namespace}:1883
   ---
   apiVersion: getambassador.io/v2
   kind:  TCPMapping
   metadata:
     name: ambassador-device-registry
     namespace: ambassador
   spec:
     port: 28080
     service: {name-of-helm-release}-service-device-registry-ext.{kubernetes-namespace}:28080
   ---
   apiVersion: getambassador.io/v2
   kind:  TCPMapping
   metadata:
     name: ambassador-dispatch-router
     namespace: ambassador
   spec:
     port: 15671
     service: {name-of-helm-release}-service-device-registry-ext.{kubernetes-namespace}:15671
   ---
   apiVersion: getambassador.io/v2
   kind:  TCPMapping
   metadata:
     name: ambassador-ditto
     namespace: ambassador
   spec:
     port: 38080
     service: {name-of-helm-release}-ditto-nginx.{kubernetes-namespace}:8080
   ```
7. Now add the mappings to your cluster: `kubectl apply -f ambassador-mappings.yaml`

You are now able to access the deployed Cloud2Edge services externally. Check what IP address you are using by
running `kubectl get service -n ambassador`.

Navigate to http://<your_ip>:38080 and check whether Ditto is running.

### Minikube

[Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) is Kubernetes in a bottle.

Instead of provisioning a full-blown cluster, it will create a virtual machine on your local system, and
provision a small, single-node cluster inside it. As it puts the operating system in a VM, Minikube itself
can run on all major operating systems, including Windows and macOS.

Instead of duplicating the effort, documenting how to get Minikube up and running, we leave this to the
excellent [documentation of Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) itself.

#### Getting started

Once you have everything installed, you should be able to start a new cluster by executing:

{%clipboard%}
minikube start
{%endclipboard%}

And you can switch `kubectl` to the context `minikube`, and interact with your cluster:

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

#### Resources

You can translate the package resources requirements into arguments for the `start` command like this:

```sh
minikube start --cpus <cpus> --disk-size <size> --memory <memory> --kubernetes-version <version>
```

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
The Kubernetes version deployed into the virtual machine (e.g. <code>--kubernetes-version v1.20.2</code>). 
</dd>

</dl>

#### Addons

Some packages may require additional addons, like the ingress addon for providing a default ingress controllers.

Such addons can be enabled when starting the Minikube instance, using the following flag:

```sh
minikube start ... --addons ingress
```

## Helm

You will need an installation of Helm on the machine which is used to deploy the packages. You can find
installation instructions for Helm in the Helm documentation under [Installing Helm](https://helm.sh/docs/using_helm/#installing-helm).

The required Helm version is 3.4 or later.

### Repository

The Eclipse IoT Packages projects hosts a Helm chart repository for Eclipse IoT projects.
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
