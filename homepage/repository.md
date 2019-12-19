---
title: 'Helm chart repository'
date: 2019-12-19T08:49:12+2:00
layout: page
lead: All the charts, in a single location.
---

The Eclipse IoT packages project decided to host a Helm chart repository in order to share the
effort of validating and publishing charts. Eclipse IoT projects are welcome to re-use that
infrastructure to publish their charts, whether they are part of an IoT package or not. Of course
projects can still host their own repositories and charts.

This repository is intended to work with Helm version 2 and 3. Features which work only with Helm 3
are labeled explicitly.

## Adding the repository

You can add the repository with a simple command:

{% clipboard %}
    helm repo add eclipse-iot https://eclipse.org/packages/charts
{% endclipboard %}

This will add the repository, using the name `eclipse-iot`. Of course you may choose
a different name here. Just take extra care when working through tutorials, as they will
expect the name to be `eclipse-iot`.

## See the content <small><span class="badge badge-secondary">Helm v3</span></small>

You can browse through the content using:

{% clipboard %}
    helm search repo --devel
{% endclipboard %}

If you want to see "under development" charts:

{% clipboard %}
    helm search repo --devel
{% endclipboard %}
