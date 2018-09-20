apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: ${cluster_name}
  name: nodes
spec:
  image: kope.io/k8s-1.8-debian-jessie-amd64-hvm-ebs-2018-01-05
  machineType: m4.2xlarge
  maxSize: 3
  minSize: 3
  role: Node
  subnets:
  - ${region}a
  - ${region}b
  - ${region}c