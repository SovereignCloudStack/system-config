---
# zuul backup cloud configuration
#
clouds:
  backup:
    auth_type: v3applicationcredential
    auth:
{{- with secret "secret/clouds/infra_backup" }}
       auth_url: "{{ .Data.data.auth_url }}"
       application_credential_id: "{{ .Data.data.application_credential_id }}"
       application_credential_secret: "{{ .Data.data.application_credential_secret }}"
{{- end }}
