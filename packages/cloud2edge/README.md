# Eclipse Cloud2Edge

The Eclipse IoT Cloud2Edge (C2E) package is an integrated suite of services developers can use to build
IoT applications that are deployed from the cloud to the edge.

The package currently consists of

* Eclipse Hono
* Eclipse Ditto

The package is supposed to provide an easy way for developers to start using Eclipse Hono and Ditto in their
IoT application.

For installation instructions and examples please visit the [Cloud2Edge home page](https://www.eclipse.org/packages/packages/cloud2edge).

Available profiles:
- [profileAmqpMessaging-values.yaml](https://github.com/eclipse/packages/blob/master/packages/cloud2edge/profileAmqpMessaging-values.yaml)
  Use AMQP messaging instead of Kafka.
- [profileTracing-values.yaml](https://github.com/eclipse/packages/blob/master/packages/cloud2edge/profileTracing-values.yaml)
  Enable tracing in Hono and Ditto and deploy the Jaeger all-in-one image as tracing backend and frontend. 
  The Jaeger UI is exposed via the `{release-name}-hono-jaeger-query` Kubernetes service. Having run the `setCloud2EdgeEnv.sh`
  script from the [tour](https://www.eclipse.org/packages/packages/cloud2edge/tour/), the URL is in the `JAEGER_QUERY_BASE_URL`
  environment variable.
- [profileOpenshift-values.yaml](https://github.com/eclipse/packages/blob/master/packages/cloud2edge/profileOpenshift-values.yaml)
  Deploy the package in Openshift.

These profiles can be applied using the `-f` parameter when installing the package via helm.
