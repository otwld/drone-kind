# drone-kind
![GitHub License](https://img.shields.io/github/license/otwld/drone-kind)
[![Build Status](https://drone.outworld.fr/api/badges/otwld/drone-kind/status.svg)](https://drone.outworld.fr/otwld/drone-kind)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/otwld/drone-kind?label=docker%20image)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/otwld/drone-kind/latest)


A Drone Plugin for Kubernetes IN Docker - local clusters for testing Kubernetes using [kubernetes-sigs/kind](https://kind.sigs.k8s.io/).

This plugin is based and inspired by the [kind-action](https://github.com/helm/kind-action).

## Usage

### Pipeline Overview
```yaml
kind: pipeline
type: docker
name: default

steps:
  - name: create kind cluster
    image: otwld/drone-kind
    settings:
      verbose: 1
      cluster_name: "kind-default"
      hostname: "kubernetes" # Use same name as service`s name
    volumes:
      - name: dockersock
        path: /var/run
      - name: kubeconfig
        path: /root/.kube
    depends_on:
      - kubernetes
  
  # Add steps for interacting with your kind cluster
  - name: kubectl example
    image: bitnami/kubectl
    commands:
      - kubectl cluster-info
    depends_on:
      - create kind cluster
    volumes:
      - name: kubeconfig
        path: /root/.kube
  
  - name: delete kind cluster
    image: otwld/drone-kind
    settings:
      clean: true
    volumes:
      - name: dockersock
        path: /var/run
      - name: kubeconfig
        path: /root/.kube
    depends_on:
      - kubernetes
  
  
# Use docker:dind for running kind
services:
  - name: kubernetes
    image: docker:dind
    privileged: true
    volumes:
    - name: dockersock
      path: /var/run

volumes:
  - name: dockersock
    temp: {}
  - name: kubeconfig
    temp: {}
```
### Pre-requisites

1. Project must be **Trusted**, Settings > General > Project Settings > Enable Trusted
2. Create a `.drone.yml` file in your root directory. [Pipelines examples](#example-pipeline) are available below.
   For more information, reference the Drone CI Help Documentation for [Pipeline Overview](https://docs.drone.io/pipeline/overview/)

### Inputs

| Setting properties | type    | default          | required      | description                                                                                                                               |
|--------------------|---------|------------------|---------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `version`          | string  | `v0.21.0`        | optional      | The kind version to use                                                                                                                   |
| `config`           | string  | ` `              | optional      | Config file for kind. For more information on the config file, see the [documentation](https://kind.sigs.k8s.io/docs/user/configuration/) |  
| `node_image`       | string  | ` `              | optional      | The node image to use if specified                                                                                                        |
| `cluster_name`     | string  | `default-kind`   | optional      | The cluster name                                                                                                                          |                                                                                                        |
| `wait`             | string  | `60s`            | optional      | Waiting time for cluster creation                                                                                                         |   
| `verbosity`        | boolean | false            | optional      | Enabled verbosity of kind                                                                                                                 |
| `kubectl_version`  | string  | `v1.28.6`        | optional      | The kubectl version to use                                                                                                                |
| `hostname`         | string  | `kubernetes`     | optional      | Specify hostname, must match the **docker:dind service name**                                                                                 |
| `clean_only`       | boolean | false            | _used for CI_ | This is used for the CI to delete the cluster.                                                                                            |
| `install_only`     | boolean | false            | _used for CI_ | This is used for the CI.                                                                                                                  |
| `install_dir`      | string  | `/usr/local/bin` | _used for CI_ | This is used for the CI.                                                                                                                  |

## Support

- For questions, suggestions, and discussion about this plugin please visit [Drone Kind Github issue page](https://github.com/otwld/drone-kind/issues)
