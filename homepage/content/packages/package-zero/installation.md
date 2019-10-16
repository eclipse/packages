---
title: 'Installation'
date: 2019-09-24T14:51:12+2:00
---

{{<content>}}

{{<content/main>}}
You will need a Kubernetes instance in order to deploy this package. If you haven't done so already, take a look at our [Kubernetes installation]({{<relref "/prereqs.md#kubernetes-cluster">}}) page. Any Kubernetes compatible cluster will do, as long as
it meets the requirements.

## Check access

Be sure that you are logged in into your Kubernetes cluster:

{{<clipboard>}}
    kubectl version
{{</clipboard>}}

This should print out the version of the client, but must also print out the version of the server.

<details>
<summary>Example output</summary>
<pre>
Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.1", GitCommit:"d647ddbd755faf07169599a625faf302ffc34458", GitTreeState:"clean", BuildDate:"2019-10-02T17:01:15Z", GoVersion:"go1.12.10", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"13+", GitVersion:"v1.13.4+c2a5caf", GitCommit:"c2a5caf", GitTreeState:"clean", BuildDate:"2019-09-21T02:12:52Z", GoVersion:"go1.11.13", Compiler:"gc", Platform:"linux/amd64"}
</pre>

</details>

## Clone repository

Clone the repository with the deployment scripts:

{{<clipboard>}}
    git clone https://github.com/eclipse/packages.git
    cd packages
{{</clipboard>}}

Change into the directory of this package:

{{<clipboard>}}
    cd packages/package-zero
{{</clipboard>}}

All further commands assume that you are operating from this directory.

## Run the deployment

First create a new namespace for the deployment:

{{<clipboard>}}
    kubectl create namespace package-zero
{{</clipboard>}}

Next, render the Helm charts:

{{<clipboard>}}
    mkdir output
    helm template . --name package-zero --namespace package-zero --output-dir output
{{</clipboard>}}

The output is in the directory `output`. It is not yet deployed, but you
can inspect it and then apply it by running:

{{<clipboard>}}
    kubectl apply -Rf output/
{{</clipboard>}}

## Monitor deployment

When you execute the following command:

{{<clipboard>}}
    kubectl get pods
{{</clipboard>}}

You should see the pods being started and becoming ready.

<details>
<summary>Example of started pods</summary>
<pre><code>NAME                                               READY   STATUS    RESTARTS   AGE
package-zero-adapter-amqp-vertx-57dc849d4c-tw25z   1/1     Running   0          148m
package-zero-adapter-http-vertx-6bdffc59-t54h5     1/1     Running   0          148m
package-zero-adapter-mqtt-vertx-74cdb9644b-6pgs6   1/1     Running   0          148m
package-zero-artemis-54ffcff88f-7w85x              1/1     Running   0          148m
package-zero-dispatch-router-54d968954b-vrp7z      1/1     Running   0          148m
package-zero-service-auth-6c9bcf8899-qmztm         1/1     Running   0          148m
package-zero-service-device-registry-0             1/1     Running   0          148m
</code></pre>
</details>

## Ready to run

Once the pods are all ready, you are ready to use the deployment. For an initial walk-through of the functionality
see the section [Take a tour]({{<relref "tour.md">}}).

{{</content/main>}}

{{<content/aside preserve="true">}}
{{<cluster-req "Kubernetes=1.15.x" "CPUs=4" "Memory=8192 MiB" "Disk=40 GiB">}}Will require cluster admin privileges.{{</cluster-req>}}
{{</content/aside>}}

{{</content>}}
