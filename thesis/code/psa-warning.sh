Warning: would violate PodSecurity "restricted:v1.26":
privileged (container "sidecar-container" must not set securityContext.privileged=true),
allowPrivilegeEscalation != false (containers "main-application", "sidecar-container" must set securityContext.allowPrivilegeEscalation=false),
unrestricted capabilities (containers "main-application", "sidecar-container" must set securityContext.capabilities.drop=["ALL"]),
restricted volume types (volume "host-root" uses restricted volume type "hostPath"),
runAsNonRoot != true (pod or containers "main-application", "sidecar-container" must set securityContext.runAsNonRoot=true),
seccompProfile (pod or containers "main-application", "sidecar-container" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
