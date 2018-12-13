apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  name: ${cluster_name}
spec:
  additionalPolicies:
    master: |
      [
        {
          "Effect": "Allow",
          "Action": [
            "route53:GetHostedZone",
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ],
          "Resource": ["arn:aws:route53:::hostedzone/*"]
        }
      ]
    node: |
      [
        {
          "Effect": "Allow",
          "Action": ["sts:AssumeRole"],
          "Resource": "*"
        }
      ]
  api:
    loadBalancer:
      type: Public
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: s3://${kops_s3_bucket}/${cluster_name}
  etcdClusters:
  - etcdMembers:
    - encryptedVolume: true
      instanceGroup: master-${region}a
      name: a
    name: main
  - etcdMembers:
    - encryptedVolume: true
      instanceGroup: master-${region}a
      name: a
    name: events
  iam:
    legacy: true
  kubeAPIServer:
    authorizationRbacSuperUser: admin
    logLevel: 1
    runtimeConfig:
      batch/v2alpha1: "true"
  kubernetesApiAccess:
  - 0.0.0.0/0
  kubernetesVersion: ${version}
  masterInternalName: api.internal.${cluster_name}
  masterPublicName: api.${cluster_name}
  networkCIDR: ${vpc_cidr}
  networkID: ${vpc_id}
  networking:
    weave:
      mtu: 8912
  nonMasqueradeCIDR: 100.64.0.0/10
  sshAccess:
  - 0.0.0.0/0
  subnets:
${private_subnets}
${public_subnets}
  topology:
    dns:
      type: Public
    masters: private
    nodes: private
