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

## Release Notes

### 0.9.1

- Use Hono 2.6.3 chart version (including updated example certificates).
- Use Ditto 3.5.10 chart version.

### 0.9.0

- Use Ditto 3.5.6 chart version.
- Use Hono 2.6.1 chart version.
- When using AMQP messaging via the [profileAmqpMessaging-values.yaml](https://github.com/eclipse/packages/blob/master/packages/cloud2edge/profileAmqpMessaging-values.yaml) profile along with the [profileTracing-values.yaml](https://github.com/eclipse/packages/blob/master/packages/cloud2edge/profileTracing-values.yaml)
  profile, there are now combined traces of Hono and Ditto. 

### 0.8.0

- Use Ditto 3.4.0 chart version. 
  Note that updating to this version requires a migration step. A rolling update is not supported.
  Refer to the Ditto migration notes for details: https://eclipse.dev/ditto/release_notes_340.html#migration-notes
- Use Hono 2.5.6 chart version.

### 0.7.0

- [#505] Use Hono chart version 2.5.5.
  This includes changes to the naming of the Hono resources (now having `{release-name}-hono` as prefix instead of `{release-name}`).
- Use Ditto chart version 3.3.7.
- Rename Ditto MongoDB resources (now having `{release-name}-mongodb` as prefix instead of `ditto-mongodb`).
- Provide profile to enable tracing.

### 0.6.0

- [#433] Restore the original service-type NodePort as default for the cloud2edge chart
  and fix the installation instructions for using service-type LoadBalancer.

### 0.5.1

- [#501] Use Ditto Connections HTTP API instead of piggyback commands.
- [#499] Fix Ditto resource config.

### 0.5.0

- [#486] Use Ditto chart version 3.3.6 from the Ditto repository.
- Update cloud2edge tour to add instructions on using the Ditto UI.
- Fix Ditto authorizationContext and connection naming.
