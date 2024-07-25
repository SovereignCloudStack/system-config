apiVersion: v1
kind: Config
current-context: zuul
preferences: {}

clusters:
  - name: zuul
    cluster:
{{- with secret "secret/kubernetes/zuul_k8s" }}
      server: "{{ .Data.data.server }}"
      certificate-authority-data: "{{ .Data.data.ca }}"
{{- end }}

contexts:
  - name: zuul
    context:
      cluster: zuul
      user: zuul-admin

users:
  - name: zuul-admin
    user:
{{- with secret "secret/kubernetes/zuul_k8s" }}
      client-certificate-data: "{{ .Data.data.client_crt }}"
      client-key-data: "{{ .Data.data.client_key }}"
{{- end }}
