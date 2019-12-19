---
title: 'Why aren''t you using Tiller?'
weight: 5
---

{% alert info: %}
This only applies to Helm 2. Tiller is no longer present in Helm 3.
{% endalert %}

Tiller is a server side component for Helm 2. It allows the Helm client, which is on your local machine,
to talk to the cluster, and let it perform the deployment.

There are several aspects to that, which make the use of Tiller complicated. The main concern is security
(also see [Exploring the Security of Helm](https://engineering.bitnami.com/articles/helm-security.html)).
The default deployment of Tiller is rather insecure. That may work on a local instance of Kubernetes,
but not when using an actual, hosted version.

And while you can configure Tiller to be less insecure, and also work on a multi-tenant cluster, this might
require permissions you don't have on that cluster. And require additional steps to set up Tiller first.

On the other hand, this project is about getting you started with IoT, not about administrating Tiller.
And since Helm allows to locally generate the YAML files, required for deployment, it seems much easier 
to only use Helm as a template tool, and use standard Kubernetes tooling to perform the deployment.
