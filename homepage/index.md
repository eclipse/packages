---
title: 'Eclipse IoT Packages™'
date: 2019-09-24T14:51:12+2:00
layout: page
introductionUrl: about
introductionText: IoT Packages is an effort of the Eclipse IoT working group, to create easy to deploy Eclipse IoT based, end-to-end scenarios on top of Kubernetes and Helm.
skipHeading: true
prependContent: pre
---

{% contentfor premain %}
<div class="container">
<div class="row justify-content-md-center">
<div class="col col-md-6 m-5">
<img class=" img-fluid" src="{{ "images/logo.svg" | relative_url }}">
</div>
</div>
</div>

{% include jumbotron.html title=page.title lead="IoT Packages is an effort of the Eclipse IoT working group, to create easy to deploy Eclipse IoT based, end-to-end scenarios on top of Kubernetes and Helm." actionUrl="/about" actionLabel="Learn more" %}

{% endcontentfor %}

{% include packages/all.html %}
