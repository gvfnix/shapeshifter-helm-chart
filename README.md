# Shapeshifter helm chart

## General info

This chart allows to utilize Helm releases without a predefined set of resources.
A chart user (developer or devops engineer) specifies the resources they need to be deployed with the release. The chart supports the following kinds of resources:

* Deployment
* Service
* Secret
* SealedSecret (bitnami)
* ConfigMap
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

### Secrets

    #values.yml
    secrets:
      database-credentials:
        password: S3cur3P@ssw0rd

### SealedSecrets

See https://github.com/bitnami-labs/sealed-secrets

    #values.yml
    sealedSecrets:
      database-credentials:
        encryptedData:
          password: |
            ...

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

