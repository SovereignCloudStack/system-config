# Keycloak

## Initial admin password

```head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 | kubectl --kubeconfig kubeconfig_wavestack_mgmt.yaml -n keycloak create secret generic keycloak-creds --from-file=admin-password=/dev/stdin```
