# Pilot

The intent of this project is to automate the deployment of Kubernetes environments. Currently the plan is to create the VPCs, subnets and DNS via terraform and then use KOps to deploy the kubernetes instances within that.

## Prequisites

 - terraform 0.11.8
 - terragrunt
 - kubectl
 - kops 1.10

## Usage

`TF_VAR_region=ap-southeast-2 TF_VAR_environment=sbx terragrunt apply`

## Caveats

### KOps

The main issue with KOps is that it is purely an Ops tool with no ability to cater for config management, continuous delivery or automation. Whilst KOps actually is all of that in terms of managing the deployment of Kubernetes, KOps itself is not designed to be triggered via any form of automation. Netiher does it allow you to hook into what it creates to allow you to extend your infrastructure around it. This is correct from the view point that Kubernetes is a PaaS and so therefore the underlying infrastructure is abstracted away and managed.

### Terraform

Terraform helps to maintain the state of the infrastructure allowing you describe your infrastructure in code. This works well with automation and CD, but the limitations are that it only can handle state that is immediately applied. It doesn't not handle transistional state such as a rolling deployment. Thus this is useful for creating the AWS resources, but not so much for deploying stateful clusters where changes to the cluster needs to be gradually rolled out.

### Terraform and KOps

Therefore a hybrid approach is being attempted in the project but again there are some limitations.
1. Even though the VPC and subnets are created via Terraform, when KOps is deployed into that network, it tags the subnets with information. Unfortunately Terraform isn't aware of this and so on the next run will attempt to remove those tags because they are not in it's configuration.
2. KOps has explicit commands for creating and updating the cluster, this means that we cannot just run a similar of an "upsert" on the cluster, making things increasing tricky to automate.
