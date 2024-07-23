---
# Nodepool openstacksdk configuration
#
# This file is deployed to nodepool launcher and builder hosts
# and is used there to authenticate nodepool operations to clouds.
# This file only contains projects we are launching test nodes in, and
# the naming should correspond that used in nodepool configuration
# files.
#
# Generated automatically, please do not edit directly!
cache:
  expiration:
    server: 5
    port: 5
    floating-ip: 5
clouds:
  gx-scs:
    auth_type: v3applicationcredential
    auth:
{{- with secret "secret/clouds/gx_scs_nodepool_pool1" }}
       auth_url: "{{ .Data.data.auth_url }}"
       application_credential_id: "{{ .Data.data.application_credential_id }}"
       application_credential_secret: "{{ .Data.data.application_credential_secret }}"
{{- end }}
