apiVersion: v1
kind: Config
current-context: zuul
preferences: {}

clusters:
  - name: zuul
    cluster:
      server: "https://31.172.117.154:6443"

contexts:
  - name: zuul
    context:
      cluster: zuul
      user: zuul-admin

users:
  - name: zuul-admin
    user:
{{- with secret "secret/kubernetes/zuul_k8s" }}
      client-certificate-data: "{{ base64Encode .Data.data.client_crt }}"
      client-key-data: "{{ base64Encode .Data.data.client_key }}"
{{- end }}
