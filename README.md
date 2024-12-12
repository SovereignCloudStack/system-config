# SCS internal infrastructure provisioning

This repository is holding public part of the infrastructure provisioning automations.

Deployment and structure of opendev and otc are being used with a single
repository (`system-config`) containing all the playbooks and public part of
the inventory, a more sensitive counterpartner repository with additional
inventory values and kubernetes application deployed with the Vault (OpenBAO)
to rely on infrastructure base authorization so that Kubernetes apps fetch
their necessary secrets directly from Vault. Please see
[opendev](https://docs.opendev.org/opendev/system-config/latest/) and
[OTC](https://docs.otc-service.com/system-config/) for the details reference.

## Inventory

System inventory is represented in the `inventory` folder. It is structured
like a standard project inventory with:

- `hosts.yaml` describes known hosts
- `group_vars` describes global variables structured per hostgroup
- `group_vars/all.yaml` variables applicable for every host
- `group_vars/ssl_cert.yaml` variables necessary for TLS certificates management
- `host_vars/` hostspecific variables

Sensitive part of the inventory hosted in the private git repository follows
the same pattern.

## Playbooks

Different parts of managed systems are configured using absible playbooks.

### base.yaml

This playbook performs basic configuration of every hosts and applies the
`base` role to it. Currently following aspects are configured:

- system package manager repositories established
- users configured in the ``inventory/group_vars/all.yaml` are provisioned to
every host with the defined public keys.
- timezone
- unbound
- firewall
- audit
- ...

### acme-certs.yaml

This playbook is responsible for managing TLS certificates for every host in
the `ssl_certs` group using ACME directory.

For every host in the `ssl_certs` group the following host variables should be
defined:

- `ssl_certs`: a dictionary of certificate information. A key is a short
certificate name (used as a file name and for internal references and a value
is a list of FQDN

Certificates are issued using Ansible `acme_certificate` module using DNS
verification. This is done since it is not uncommon that certain certificates
must be valid for variety of the domain names (i.e. vault.infra.XXX and
vault1.infra.XXX). `dns_cloud` variable (typically set on the `ssl_certs` group
must point to the cloud configured on the controller host and point to the
OpenStack cloud hosting the DNS zone. It is important to mention that records
are placed into the DNS zone named one level higher then requested record
(vault.infra.XXX is placed into the infra.XXX zone).

Certain systems get notified when the certificate is renewed (i.e. vault) and
are automatically restarted.

Further description is present in the header of the playbook itself.

### provision-vault.yaml

Provisions a new host as OpenStack VM (creates new VM). For that host_vars for
the specific host are being used: image, flavor, security_groups, ...

This playbook is intended to be used only once to create new VM.

Vault policies and auth configurations are considered to be sensitive
information therefore they are placed in the suplementary sensitive repository.

### service-vault.yaml

This playbook configures Vault (OpenBAO) software on the hosts in the `vault`
group. There are may specific variables influencing how the software is
configured.

The playbook is not responsible for vault operations (sealing, unsealing) but
is configuring HA cluster when enough hosts are provisioned.


## Kubernetes applications

Certain systems are deployed into the Kubernetes with the help of Kustomize.
This allows easier integration with ArgoCD or FluxCD.

Typically applications can be installed manually

```
kubectl kustomize kubernets/<APP>/overlays/<OVERLAY_NAME> | kubectl [--kubeconfig <PATH_TO_CONFIG>] apply -f -
```

Typically overlay kustomization file is responsible for components versions.

### Zuul

This Kustomize application installs Zuul into the Kubernetes. Secrets are
fetched from Vault directly, therefore no sensitive information is required to
be present what makes it trivial to rely on ArgoCD (or similar).

More details are present in the application's [Readme file](kubernetes/zuul/README.md)

It is required that [Certmanager](kubernetes/certmanager-issuer),
[Cloudnative-pg](kubernetes/cloudnative-pg) and [Ingress
controller](kubernetes/ingress) to be installed in the target Kubernetes
cluster as well.


### Keycloak

This application installs Keycloak. Unfortunately not everything can be easily
configured in the declarative style in Keycloak, therefore parts of the realms
configs cannot be placed here.

Please ensure backup procedures (beyond the regular DB backups performed by the
cloudnative-pg) exist.


### Delendency-track

Installs DependencyTrack with the database. Keycloak integration is also
prepared while the Keycloak integration () is out of scope.

On the DependencyTrack side a `/dependencytrack-admin` (`/` is crucially
important in the group name) must be present in `Administration/Access
Management/OpenID Connect Groups` and all Keycloak member assigned to group
with this name in Keycloak are assigned `admin` privileges in the
DependencyTrack ([Integration
documentation](https://docs.dependencytrack.org/getting-started/openidconnect-configuration/#example-setup-with-keycloak)
can be used for reference).

### DefectDojo

Unfortunately there are no working plain Kubernetes manifests exist for
DefectDojo therefore Kustomize stack wraps helm. This requires (as of writing)
passing additionally `--enable-helm` to the `kubectl kustomize` to render
manifests.
