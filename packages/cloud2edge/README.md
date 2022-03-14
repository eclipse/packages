# Eclipse Cloud2Edge

The Eclipse IoT Cloud2Edge (C2E) package is an integrated suite of services developers can use to build
IoT applications that are deployed from the cloud to the edge.

The package currently consists of

* Eclipse Hono
* Eclipse Ditto

The package is supposed to provide an easy way for developers to start using Eclipse Hono and Ditto in their
IoT application.

For installation and examples please visit [Cloud2Edge home page](https://www.eclipse.org/packages/packages/cloud2edge)

There are two profiles to deploy the cloud2edge package. The first one `profileOpenshift.yaml` can be used to deploy into 
an Openshift cluster and the second one `profileKafkaMessaging.yaml` to use Kafka messaging for the Eclipse Hono project.
It is possible to specify both profiles with the -f parameter when installing the package via helm.
