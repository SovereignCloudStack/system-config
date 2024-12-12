# Kustomize stack for installing Zuul

This folder contains Kubernetes manifests processed by Kustomize application in
order to generate final set of manifests for installing Zuul into the
Kubernetes.

## Components

Whole installation is split into individual components, so that it is possible
to configure what to use in a specific installation:

### ca

Zuul requires Zookeeper in HA mode with TLS enabled to function. It is possible
to handle TLS outside of the cluster, but it is also possible to rely on
cert-manager capability of having own CA authority and provide certificates as
requested. At the moment this is set as a hard dependency in the remaining
components, but it would be relatively easy to make it really optional
component.

### Zookeeper

This represents a Zookeeper cluster installation. No crazy stuff, pretty
straigt forward

### zuul-scheduler

Zuul scheduler

### zuul-executor

Zuul executor

### zuul-merger

Optional zuul-merger

### zuul-web

Zuul web frontend

### nodepool-launcher

Launcher for VMs or pods

### nodepool-builder

Optional builder for VM images. At the moment it is not possible to build all
types of images inside of Kubernetes, since running podman under docker in K8
is not working smoothly on every installation

## Layers

- `base` layer is representing absolutely minimal installaiton. In the
  kustomization.yaml there is a link to zuul-config repository which must
  contain `nodepool/nodepool.yaml` - nodepool config and `zuul/main.yaml` -
  tenants info.  This link is given by `zuul_instance_config` configmap with
  ZUUL_CONFIG_REPO=https://github.com/SovereignCloudStack/zuul-config.git

- `zuul_ci` - zuul.sovereignit.cloud installation

## Versions

Zookeeper version is controlled through
`components/zookeeper/kustomization.yaml`

Zuul version by default is pointing to the latest version in docker registry
and it is expected that every overlay is setting desired version.

Proper overlays are also relying on HashiCorp Vault for providing installation
secrets. Vault agent version is controlled i.e. in the overlay itself with
variable pointing to the vault installation in the overlay patch.

## Vault

This application (overlay) is designed to fetch all necessary data from Vault
using [vault-agent](https://openbao.org/docs/agent-and-proxy/agent/). For this
a series of vault-agent configs are created as Kubernetes ConfigMaps. Every
Zuul component pod is provisioned with a vault-agent sidecar (typically 2: init
container to render initial configuration and run container to keep
configuration synchronized).

Depending on the component and patching style Vault address may be passed on the patch itself as an environment variable to the vault-agent pods. In addition to that Zuul itself may need to know location of Vault to be able to use it for dynamic credentials lookup by jobs (overlays/configs/site-vars.yaml).

Every vault-agent config file contain Vault connection information

```
    "method" = {
        "mount_path" = "auth/kubernetes_wavestack_zuul"
        "config" = {
          "role" = "zuul"
        }
        "type" = "kubernetes"
```

This requires a Kubernetes Auth to be registered in the Vault with the name
`kubernetes_wavestack_zuul` and a role `zuul` providing read access to
necessary secrets.

### Jobs accessing Vault

It is possible to configure Zuul jobs to fetch necessary secrets from Vault
directly instead of relying on the default Zuul mechanism storing encrypted
secrets in git repository. This gives much better control over secrets, ease
rotation and provide access audit.

A base vault token (`zuul-base` K8 role) is being provisioned by vault-agent into the zuul-executor trusted-ro path making it accessible to the [Zuul base job](https://github.com/SovereignCloudStack/zuul-scs-jobs/blob/main/playbooks/base/pre.yaml). This job is using it in few ways:

- directly [fetch logs cloud access credentials](https://github.com/SovereignCloudStack/zuul-scs-jobs/blob/main/playbooks/base/post-logs.yaml#L9) to upload job logs
- issue a one-time [sealed approle
  access](https://openbao.org/docs/auth/approle/) for jobs running in the
  post-review pipeline and having vault_role_id job variable defined pointing to
  the existing AppRole with the name matching the project name constructed in the
  following way: "zuul/<TENANT_NAME>/<REPOSITORY_NAME>" ([example
  job](https://github.com/SovereignCloudStack/zuul-scs-jobs/blob/main/playbooks/container-image/upload.yaml)).
  The job is capable to unseal the one-time secret using the base token.

## Configuration repositories

There 2 basic git repositories used by Zuul:

- [Zuul config](https://github.com/SovereignCloudStack/zuul-config/)

  This repository is defining zuul deployment configuration (nodepool config,
  zuul tenant config)

- [Jobs](https://github.com/SovereignCloudStack/zuul-scs-jobs/)

  This repository defines SCS tenant configuration (jobs)
