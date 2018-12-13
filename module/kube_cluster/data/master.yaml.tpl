apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: ${cluster_name}
  name: master-${region}${az}
spec:
  image: ${ami}
  machineType: m4.large
  maxSize: 1
  minSize: 1
  role: Master
  subnets:
  - ${region}${az}
