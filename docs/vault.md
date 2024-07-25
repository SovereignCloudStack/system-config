# Vault (HashiVault/OpenBAO)

[Vault](openbao.org) is used in our infrastructure to manage secrets required
by diverse elements of the infrastructure. We currently have a single node
installation due to resource constraints, but ideally would go to 1 transit + 3
nodes HA cluster setup. Vault is not deployed on the Kubernetes due to the need
to unseal it every time Kubernetes decides to reschedule the pod. In addition
to that outage of Kubernetes would lead to unavailability of Vault which would
be hard to deal with since Vault is also used in many cases to provide secrets
to the applications running inside of Kubernetes.

## VM

### Provisioning

Provisioning of VM is done by Ansible. Command `ansible-playbook -i inventory
playbooks/provision-vault.yaml` is taking care of deploying the host onto the
cloud (and with properties) defined as host variables (both
`inventory/hosts.yaml` and
`inventory/host_vars/vault1.infra.sovereignit.cloud.yaml`. Please note that
since at the moment the playbook is executed on the localhost by a human (to be
changed in next future) it is expected that `clouds.yaml` config is containing
required connections.

### Configuration

Configuring the VM and the software on it is also done by Ansible.

- `playbooks/base.yaml` - intended to be executed on all infrastructure hosts
  and deal with basic host configuration, security, users, logs, etc

- `playbooks/service-vault.yaml` - configures Vault

- `playbooks/acme-certs.yaml` - Manage TLS certificates on hosts by issuing and
  renewing them with LetsEncrypt using the DNS based verification. For that a
  cloud `scs_dns` must be present on the controller host.

## Bootstrap

Running Vault requires initial bootstrap. It is described
[here](https://openbao.org/docs/commands/operator/init/), but is pretty much a
single command `bao operator init`. It produces 5 Unseal tokens together with
initial root token. Those must be treated as very sensitive data. Use of 3
different keys is required to unseal the Vault. Ideally unseal keys are spread
across the team so that no single person have access to more then 2 values.

## Operations

There are different aspecs of activities for operating Vault.

### Vault configuration

Vault as a service offers multiple resources (auth types, secret plugins,
secrets, audit devices, ...) requiring configuration. It is possible and highly
recommended to be performed using declarative approach (i.e. with Ansible) to
be able to permanently audit current desired configuration and easily modify
it. This configuration on it's own is not a secret, but since it exposes
insights on usage of Vault we keep this not publicly available (in a private
git repository).

- `playbooks/bootstrap-vault.yaml` - a one time configuration bootstrap. It
  enables at minimum required authorization plugins. Typically it is executed
  only once using the initial root token obtained during initializing Vault.

  After executing this it is recommended to obtain a dedicated credentials for
  further operations.

  `bao read auth/approle/role/system-config-vault/role-id" to get the ROLE_ID
  `bao write auth/approle/role/system-config-vault/secret-id" to get the ROLE_SECRET_ID

- `playbooks/configure-vault.yaml` - Configuration itself. Data is being
  descried in the `inventory/group_vars/vault-controller.yaml` of the private
  repository.
