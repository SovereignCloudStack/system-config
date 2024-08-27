# DefectDojo installation

This Kustomize stack installs DefectDojo application.

DefectDojo is barely customizable application. It supports lot of configuration
options in the HelmChart, but none of that allows following security best
practices. Moreover it is not even supporting idempotency of calling helm with
same parameters (due to the approach used for secrets handling).

It hardwires the redis from bitnami charts (which requires fixing of the
apiVersion of the PodDisruptionBudget). Replacing Redis with ValKey is not as
easy as one might think, therefore for the moment this is out of scope.

The stack of components here consists of:

  - namespace creation
  - database managed by cloudnative operator
  - DefectDojo manifests generated from helm chart with patches (apiVersion of
    the redis pdb, rename Job not to run every time the kustomize is applied)
