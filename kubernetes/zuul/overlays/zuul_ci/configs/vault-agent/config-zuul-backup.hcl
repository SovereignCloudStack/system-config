pid_file = "/home/vault/.pid"
"auto_auth" = {
    "method" = {
        "mount_path" = "auth/kubernetes_wavestack_zuul"
        "config" = {
          "role" = "zuul"
        }
        "type" = "kubernetes"
      }
    sink "file" {
        config = {
            path = "/home/vault/.token"
        }
    }
}

cache {
}

api_proxy {
  use_auto_auth_token = true
}

# Vault agent requires at least one template or listener is present. Add a socket
listener "unix" {
    address = "/home/vault/vault_agent.socket"
    tls_disable = true
}

template {
  destination = "/vault/secrets/zuul.conf"
  source = "/vault/custom/zuul.conf.hcl"
  perms = "0644"
}

template {
  destination = "/vault/secrets/openstack/clouds.yaml"
  source = "/vault/custom/clouds-backup.yaml.hcl"
  perms = "0640"
}


