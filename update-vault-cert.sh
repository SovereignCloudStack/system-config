#!/bin/bash
export OS_CLOUD=${OS_CLOUD:-cnds-dns}
openstack catalog list >/dev/null 2>&1
if test $? != 0; then echo "Fix your openstack access to $OS_CLOUD"; exit 1; fi
SSHKEYS=$(ssh-add -l)
if test -z "$SSHKEYS"; then echo "Need ssh key agent running"; exit 1; fi
echo ansible-playbook -e dns_cloud=$OS_CLOUD -i inventory playbooks/acme-certs.yaml
exec ansible-playbook -e dns_cloud=$OS_CLOUD -i inventory playbooks/acme-certs.yaml
