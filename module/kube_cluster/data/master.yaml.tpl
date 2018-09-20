apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: ${cluster_name}
  name: master-${region}${az}
spec:
  image: kope.io/k8s-1.8-debian-jessie-amd64-hvm-ebs-2018-01-05
  machineType: m4.large
  maxSize: 1
  minSize: 1
  role: Master
  subnets:
  - ${region}${az}