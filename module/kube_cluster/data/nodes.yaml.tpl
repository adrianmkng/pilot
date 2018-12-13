apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: ${cluster_name}
  name: nodes
spec:
  image: ${ami}
  machineType: m4.2xlarge
  maxSize: 3
  minSize: 3
  role: Node
  subnets:
  - ${region}a
  - ${region}b
  - ${region}c
