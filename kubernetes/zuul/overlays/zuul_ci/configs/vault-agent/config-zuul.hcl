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
  destination = "/vault/secrets/connections/github.key"
  contents = <<EOT
{{- with secret "secret/zuul/connections/github" }}{{ .Data.data.app_key }}{{ end }}
EOT
  perms = "0600"
}
template {
  destination = "/vault/secrets/zuul.conf"
  source = "/vault/custom/zuul.conf.hcl"
  perms = "0644"
  # exec = { command = "sh -c '{ if [ -f /secrets/config.check ]; then kubectl -n zuul-ci rollout restart statefulset zuul-executor; else touch /secrets/config.check; fi }'", timeout = "30s" }
}
template {
  destination = "/vault/secrets/sshkey"
  contents = <<EOT
{{- with secret "secret/zuul/sshkey" }}{{ .Data.data.private_key }}{{ end }}
EOT
  perms = "0600"
}
