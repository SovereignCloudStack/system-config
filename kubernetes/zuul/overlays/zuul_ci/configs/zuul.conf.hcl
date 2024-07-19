[zookeeper]
hosts=zookeeper.zuul-ci.svc.cluster.local:2281
tls_cert=/tls/client/tls.crt
tls_key=/tls/client/tls.key
tls_ca=/tls/client/ca.crt
session_timeout=40

[scheduler]
#tenant_config=/etc/zuul-config/zuul/main.yaml
tenant_config_script=/etc/zuul-config/tools/render_config.py
state_dir=/var/lib/zuul
relative_priority=true
prometheus_port=9091

[web]
listen_address=0.0.0.0
port=9000
status_url=https://zuul.sovereignit.cloud
root=https://zuul.sovereignit.cloud
prometheus_port=9091

[fingergw]
port=9079
user=zuul

[keystore]
{{- with secret "secret/zuul/keystore_password" }}
password={{ .Data.data.password }}
{{- end }}

[merger]
git_dir=/var/lib/zuul/git
git_timeout=600
git_user_email=zuul@zuul.sovereignit.cloud
git_user_name=SCS Zuul
prometheus_port=9091

[executor]
manage_ansible=true
ansible_root=/var/lib/zuul/managed_ansible
private_key_file=/etc/zuul/sshkey
disk_limit_per_job=2000
max_starting_builds=5
trusted_ro_paths=/var/run/zuul/trusted-ro
variables=/var/run/zuul/vars/site-vars.yaml
prometheus_port=9091

[database]
dburi=%(ZUUL_DB_URI)

[connection "github"]
name=github
driver=github
{{- with secret "secret/zuul/connections/github" }}
webhook_token={{ .Data.data.webhook_token }}
app_id={{ .Data.data.app_id }}
{{- end }}
app_key=/etc/zuul/connections/github.key

[connection "opendev"]
name=opendev
driver=git
baseurl=https://opendev.org

[auth "keycloak"]
default=True
driver=OpenIDConnect
realm=eco
issuer_id=https://keycloak.eco.tsi-dev.otc-service.com/realms/eco
client_id=zuul
