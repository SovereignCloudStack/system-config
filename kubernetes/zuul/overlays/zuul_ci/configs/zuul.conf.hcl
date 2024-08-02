[zookeeper]
hosts=zookeeper.zuul-ci.svc.cluster.local:2281
tls_cert=/tls/client/tls.crt
tls_key=/tls/client/tls.key
tls_ca=/tls/client/ca.crt
session_timeout=40

[scheduler]
tenant_config=/etc/zuul-config/current/zuul/main.yaml
state_dir=/var/lib/zuul
relative_priority=true
prometheus_port=9091

[web]
listen_address=0.0.0.0
port=9000
status_url=https://zuul.sovereignit.cloud
root=https://zuul.sovereignit.cloud
prometheus_port=9091

# [fingergw]
# port=9079
# user=zuul

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
dburi=postgresql://{{ file "/vault/db-secrets/user" }}:{{ file "/vault/db-secrets/password" }}@{{ file "/vault/db-secrets/host" }}/{{ file "/vault/db-secrets/dbname" }}?sslmode=require

[connection "github"]
name=github
driver=github
{{- with secret "secret/zuul/connections/github" }}
webhook_token={{ .Data.data.webhook_token }}
app_id={{ .Data.data.app_id }}
{{- end }}
app_key=/etc/zuul/connections/github.key

[connection "opendevorg"]
name=opendev
driver=git
baseurl=https://opendev.org

[statsd]
{{- with secret "secret/zuul/connections/statsd" }}
server={{ .Data.data.server }}
port={{ .Data.data.port }}
{{- end }}

# TODO(gtema): add the real one
[connection "mqtt"]
name=mqtt
driver=mqtt
server=mqtt-broker
port=1883
user=dummy
password=dummy

[auth "keycloak"]
default=True
driver=OpenIDConnect
realm=master
issuer_id=https://keycloak.infra.sovereignit.cloud/realms/master
client_id=zuul
