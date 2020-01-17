---
title: 'Contributions welcome'
date: 2019-09-24T14:51:12+2:00
layout: page
lead: Contributions to this project are very welcome. And contributions can come in many different forms, one of the is code.
---

## Providing feedback

Feedback is always welcome. The more constructive it is, the more impact it will have.

The easiest way to provide feedback is through
[GitHub issues](https://github.com/eclipse/packages/issues) of the project.

## Join the community call

Starting <time datetime="2019-12-02">2019-12-02</time>, we have a quick (30min), bi-weekly
community call at <time datetime="16:00">16:00</time> CET. This is an open call,
everyone is welcome to join.

The URL to the call is: [https://eclipse.zoom.us/j/317801130](https://eclipse.zoom.us/j/317801130).

You may also directly subscribe to the [community calendar](https://calendar.google.com/calendar/ical/lu98p1vc1ed4itl7n9qno3oogc%40group.calendar.google.com/public/basic.ics).

## Contact us on Gitter

We also do have a channel on Gitter: [https://gitter.im/eclipse/packages](https://gitter.im/eclipse/packages "Gitter Channel").

## Improving an existing package

There is always room for improvement. Found a bug, have an idea how to make things better.
Make a change and create a pull request.

## Extending an existing package

Got a cool idea on adding something new to an existing package? It makes sense to create an issue on GitHub,
and discuss your proposal. The existing maintainers of a package might want to understand how this fits
into their package, what the benefit is, and what is required. Get in touch, get on the same page, and start coding.

## Creating a new package

Found some Eclipse IoT projects that would make a great package? Then don't hesitate to create a
PR against this repository which contains your new package. Please make sure that your PR's description
explains why you think this new package should be created. Note that by adding a new package you
are expected to take ownership of the package as well.

## Requirements for packages

Regardless of whether you want to contribute a small change only or a completely new package, there
are some qualitative requirements that all packages and the charts they contain must meet.

All IoT Packages must

* comprise of at least two Eclipse IoT projects that provide a real benefit when being
  integrated with each other in this way.
* only contain artifacts that are distributed under a license that is compatible with the EPLv2.
* only contain stable, released versions of project artifacts (no milestones or snapshots).
* must contain
  * a README covering a basic introduction and the idea behind the package,
  * the Helm charts constituting the components of the package,
  * some guidance regarding what users might want to do with the package after installation.

IoT Packages are implemented by means of Helm charts that are combined together and configured in
a particular way. An IoT Package must not *contain* the Helm charts of the projects it comprises of
but instead must only *refer* to the projects' Helm charts which are maintained and distributed separately.
This allows for a modular approach where projects can easily be (re)used in multiple IoT Packages.

The IoT Packages GitHub repository can be used to maintain both individual charts for Eclipse IoT Projects
as well as packages that are comprised of multiple projects:

* The `charts` folder contains Helm charts for Eclipse IoT projects. Each sub-folder contains a chart for
  one project.
* The `packages` folder contains the IoT packages. Each sub-folder represents one package.

## Requirements for charts

All Helm charts in the repository must meet the following technical and documentation requirements.

### Technical requirements

Helm charts

* must not contain other charts that they depend on
* must pass the Helm linter (`helm lint`)
* must successfully launch with default values (`helm install .`)
    * all pods go to the running state (or NOTES.txt provides further instructions if a required value is missing e.g. [minecraft](https://github.com/helm/charts/blob/master/stable/minecraft/templates/NOTES.txt#L3))
    * all services have at least one endpoint
* must contain pointers to source GitHub repositories for images used in the chart
* must not use container images that have any major security vulnerabilities
* must be up-to-date with the latest stable Helm/Kubernetes features
    * use Deployments in favor of ReplicationControllers
* should follow Kubernetes best practices
    * include Health Checks wherever practical
    * allow configurable [resource requests and limits](http://kubernetes.io/docs/user-guide/compute-resources/#resource-requests-and-limits-of-pod-and-container)
* must provide a method for data persistence (if applicable)
* must support application upgrades
* must allow customization of the application configuration by means of Helm properties
* must provide a secure default configuration
* must not leverage alpha features of Kubernetes
* must include a [NOTES.txt](https://github.com/helm/helm/blob/master/docs/charts.md#chart-license-readme-and-notes) explaining how to use the application after install
* must follow [best practices](https://github.com/helm/helm/tree/master/docs/chart_best_practices)
  (especially for [labels](https://github.com/helm/helm/blob/master/docs/chart_best_practices/labels.md)
  and [values](https://github.com/helm/helm/blob/master/docs/chart_best_practices/values.md))

### Documentation Requirements

Helm charts

* must include a `README.md`, containing:
    * a short description of the chart
    * any prerequisites or requirements
* must include a short `NOTES.txt`, containing:
    * any relevant post-installation information for the chart
    * instructions on how to access the application or service provided by the chart
* must contain a `values.yaml` file which contains a reasonable default configuration and explains
  how the properties can be used to customize the chart

## Merge approval and release process

All pull requests will be verified by a CI job which runs the linter and tries to install the chart to at least the three most recent minor releases of kubernetes.
At least one maintainer needs to explicitly approve the PR before it can be merged.

Once the Chart has been merged, a CI job will automatically package and release the Chart in the [Eclipse IoT Packages repository](https://eclipse.org/packages/repository/).

## The legal side of things

If you plan on contributing code, you will need to
[create an Eclipse Foundation account](https://accounts.eclipse.org/user/register),
and [sign the Eclipse Contributor Agreement](https://accounts.eclipse.org/user/eca).

Is this required? Yes! Is there a way around it? No! Why is this necessary? Because legal
issues are as though as software engineering issues, and this is the way to solve them.

