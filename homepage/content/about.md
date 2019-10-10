---
title: 'About'
date: 2019-09-24T14:51:12+2:00 
---

{{<row>}}

{{<col "md-9">}}

<p class="lead">
Eclipse IoT packages provide recipies for combining Eclipse IoT projects,
to solve real world IoT problems.
</p>

The Eclipse IoT Packages project provides a home for use case focused IoT deployments,
based on Eclipse IoT technology. It takes the building blocks that the different projects provide,
and adds the necessary glue code, needed to create more complete setups. It acts as a showcase of what
is possible with Eclipse IoT, and enables you to try it out first hand.
{{</col>}}

{{<col "md-9">}}

## Concept of a package

IoT Packages are a combination of two or more Eclipse IoT projects, combined in an integrated way,
leveraging the benefits of each project, to showcasing the benefit of their integration.

The goal is to help people understand, what problems the combination of Eclipse IoT projects can solve.
And also enable them to try it out themselves, within minutes and on their own infrastructure.

Packages not only to provide deployments scripts, but also some description what the benefit of the
integrated package is, and some initial, tutorial like steps, to play with the setup, once it is deployed.

{{</col>}}

{{<col "md-3" "pl-md-5">}}{{<img-fluid src="/images/eclipse-IoT-light.png">}}{{</col>}}

{{</row>}}

## Common cloud foundation

{{<row>}}

{{<col "md-8">}}

Because integrating different software components is already hard enough, the IoT packages project
chose Kubernetes as its cloud side deployment platform. Kubernetes is the de-facto standard for
containerized deployments in the cloud. And so it makes sense to focus on this platform, and have a common
base for all IoT packages.

Helm is an tool which integrates nicely with Kubernetes. It is easy to use, and has the ability to create
a set of YAML files, which are easy to deploy.

{{</col>}}

{{<col "md-4" "pl-md-5">}}{{<row>}}
{{<col>}}{{<img-fluid src="/images/kubernetes.svg">}}{{</col>}}
{{<col>}}{{<img-fluid src="/images/helm.png">}}{{</col>}}
{{</row>}}{{</col>}}

{{</row>}}

## A home for glue code

Bringing together different building blocks will leave a few gaps here and there. Some things make only
sense in a bigger context.

Hosting glue code, or glue functionality that is required to bring projects together, is also one aspect
of the IoT packages projects. Projects are encouraged to integrate as much functionality as possible into
their own code base. But whenever there is something which doesn't properly fit into either of the projects,
the IoT Packages project can be home to this glue code.

## Contributions welcome

Contributions of all kinds are welcome. Adding new packages, enhancing or refining existing ones. Content will
be licensed under the EPL. And while we think that open source is the right model, you are more than
welcome to fork a package, and add your custom, closed source code functionality, in order to showcase how
awesome Eclipse IoT is.

You can read more about contributing on our dedicated [contributions guide]({{<relref "contribute.md">}}).
