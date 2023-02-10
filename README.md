# Shapeshifter helm chart

## General info

This chart allows to utilize Helm releases without a predefined set of resources.
A chart user (developer or devops engineer) specifies the resources they need to be deployed with the release. The chart supports the following kinds of resources:

* Deployment
* Service
* Secret
* SealedSecret (bitnami)
* ConfigMap
* Job
* CronJob
* Custom resources

As lists are not easy to merge, this chart is aimed to make overriding values as convenient as possible. It avoids lists usage in values.

## Usage

### Deployments

    # values.yml:
    deployments:
      podinfo:
        pod:
          containers:
            app:
              image:
                repository: quay.io/stefanprodan/podinfo
                tag: 3.3.1

This values file will generate a simplest deployment called "podinfo". This "podinfo" deployment has all required labels to control the pods and also adds "config.checksum" annotation to update pods when any of `configMaps`, `secrets` or `sealedSecrets` gets updated.

#### Adding environment variables to a container

    # values.yml:
    configMaps:
      podinfo-conf:
        ui-color: "#CCCCCC"
    deployments:
      podinfo:
        pod:
          containers:
            app:
              image:
                repository: quay.io/stefanprodan/podinfo
                tag: 3.3.1
              env:
                PODINFO_UI_MESSAGE: "Hi there"
                PODINFO_UI_COLOR:
                  valueFrom:
                    configMapKeyRef:
                      name: podinfo-conf
                      key: ui-color
                      optional: true

As it can be observed, `env` section here is a map rather than a list. This makes it much easier to override a single variable value: `helm updgrade -i demo1 chart/ -f values.yml --set deployments.podinfo.pod.containers.app.env.PODINFO_UI_COLOR="#BBBBBB"`

#### Using volumes

    # values.yml:
    deployments:
      podinfo:
        pod:
          volumes:
            empty1:
              emptyDir:
                medium: Memory
          containers:
            app:
              image:
                repository: quay.io/stefanprodan/podinfo
                tag: 3.3.1
              mounts:
                /var/lib/localData:
                  volume: empty1

#### Adding a service to a deployment

    # values.yml:
    deployments:
      podinfo:
        pod:
          containers:
            app:
              image:
                repository: quay.io/stefanprodan/podinfo
                tag: 3.3.1
              ports:
                http:
                  containerPort: 9898
        service:
          enable: true
          metadata:
          annotations:
            external-dns.alpha.kubernetes.io/hostname: my-podinfo.domain.org
          spec:
            type: LoadBalancer

This snippet adds a deployment along with a LoadBalancer service. Port 9898 is exposed.

### ConfigMaps

    #values.yml
    configMaps:
      simple-conf:
        parameter1: value1
        parameter2: |
          multi-line
          value2
        # also supports YAML
        parameter3:
          subParameter1: subvalue1
          subParameter2: subvalue2

### Secrets

    #values.yml
    secrets:
      database-credentials:
        password: S3cur3P@ssw0rd
        # also supports YAML
        sensitive-config.yaml:
          api:
            url: https://some.api.com/v1
            key: absys6-d-7

### SealedSecrets

See https://github.com/bitnami-labs/sealed-secrets

    #values.yml
    sealedSecrets:
      database-credentials:
        encryptedData:
          password: |
            ...

### Jobs

See [test values](./chart/tests/job_values.yaml)

### CronJobs

See [test values](./chart/tests/cronJob_values.yaml)

### Custom resources

    #values.yml
    customResources:
      kafkaTopic1:
        definition:
          apiVersion: kafka.strimzi.io/v1beta2
          kind: KafkaTopic
          metadata:
            labels:
              strimzi.io/cluster: some-cluster
          spec:
            partitions: 3
            replicas: 3
        instances:
          some-topic:
            spec:
              config:
                retention.ms: 96000
          another:
            metadata:
              labels:
                extraLabel: someLabelValue

This snippet creates 2 `kafka.strimzi.io/v1beta2/KafkaTopic` resources with corresponding names.

## Configuration reference

### Deployments

* `deployments.NAME` (map): configuration of the deployment.

Deployment configuration parameters:
* `apiVersion` (str): override default apiVersion for the deployment (default `apps/v1`). Implemented for outdated K8S versions compatibility.
* `spec` (map): set deployment-specific parameters (see [DeploymentSpec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/#DeploymentSpec) for more details).
* `pod` (map): set pod-specific parameters (see below).
* `service`: Service configuration (see below).


### StatefulSets

* `statefulSets.NAME` (map): configuration of the statefulSet.

StatefulSet configuration parameters:

* `apiVersion` (str): override default apiVersion for the deployment (default `apps/v1`). Implemented for outdated K8S versions compatibility.
* `spec` (map): set statefulSet-specific parameters (see [StatefulSetSpec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/stateful-set-v1/#StatefulSetSpec)).
* `pod` (map): set pod-specific parameters (see below).
* `service`: Service configuration (see below).

### Pods

See [PodSpec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec) for more details. All properties can be specified for pod template. If the property is not listed below, then it can be used just like in the docs. If the property is listed below, then it is modified.

`volumes` (map): See below.
`containers` (map): see below.

### Volumes

* `volume.NAME` (map): volume configuration.

Volume configuration parameters are not modified. The only thing that changed is that `volumes` property is not a list, but is a map.

    volumes:
      persistentVolumeClaim:
        claimName: "basic"

### Containers

* `containers.NAME` (map): container configuration.

Container properties are mostly preserved from [ContainerSpec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container). Changed properties are listed below:

* `image.repository` (string): repository of the container image.
* `image.tag` (string): tag of the container image.
* `image.pullPolicy` (string): imagePullPolicy to use.
* `env` (map): environment variables. Each item should be set as `{"key": "value"}` or as `{"key": {"valueFrom": {...}}}`.
* `mounts` (map): volume mounts. Each item should be set as `{"path": {"volume": "NAME"}}`. A path can be mounted from a single volume, but a volume can be mounted into multiple paths. Additional properties for path can be found [in API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#volumes-1), e.g. `{"/mnt/one": {"volume": "one", "readOnly": true}}`.
* `ports` (map): container ports. Minimal use is `{"NAME": {"containerPort": NUMBER}}`. Additional properties can be set as `hostIP`, `hostPort`, `protocol` (`TCP` or `UDP`) and `servicePort`. `servicePort` is applied when exposing container ports through a service. If `servicePort` is not set, then service will use `containerPort`.

### Services

Each `deployment` or `statefulSet` defined in values can be provided with a service like this:

    #values.yml
    deployments:
      deploymentOne:
        ...
        service:
          ...
    statefulSets:
      statefulSetOne:
        ...
        service:
          ...

If `service` property is a non-empty map, then the chart will add a `v1/Service` resource to the rendered set of resources.

Service properties:

* `annotations` (map).
* `spec` (map): additional service properties (see [API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/)).

Currently service exposes all containerPorts.
