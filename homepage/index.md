---
title: 'Eclipse IoT Packages™'
date: 2019-09-24T14:51:12+2:00
layout: page
introductionUrl: about
introductionText: Eclipse IoT Packages™ is an effort of the Eclipse IoT working group, to create easy to deploy Eclipse IoT based, end-to-end scenarios on top of Kubernetes and Helm.
skipHeading: true
prependContent: pre
---

{% contentfor premain %}
<div class="container">
<div class="row">
<div class="col col-md-5 my-5">
<img class=" img-fluid" src="{{ "images/logo.svg" | relative_url }}">
</div>
</div>
</div>

{% include jumbotron.html lead="Eclipse IoT Packages™ is an effort by the Eclipse IoT working group, to create easy to deploy Eclipse IoT based, end-to-end scenarios, on top of Kubernetes and Helm." actionUrl="/about" actionLabel="Learn more" %}

{% endcontentfor %}

{% include packages/all.html %}
