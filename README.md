# Kops-BJS

This tutorial will walk you through building a Kubernetes cluster with [Kops](https://github.com/kubernetes/kops) in AWS Beijing Region.



### Agenda

**Prepare the AMI** 

**Install Kops and Kubectl client on your laptop**

**Create a proxy server with gost in AWS N. Virginia Region**

**Create a proxy forwarder in AWS Beijing Region**

**Create the cluster with Kops**



### Prepare the AMI 

Check the latest AMI ID from [Kops Images](https://github.com/kubernetes/kops/blob/master/docs/images.md) document and find the AMI ID in the global regions(e.g. N. Virginia).

For example, you can find the latest CoreOS AMI in us-esat-1 like this:

```
$ curl -s https://coreos.com/dist/aws/aws-stable.json | jq -r '.["us-east-1"].hvm'
ami-9e2685e3
```

Then follow [this comment](https://github.com/kubernetes-incubator/kube-aws/pull/390#issue-212435055) to copy the AMI from us-west-1 to China Beijing region.

Or just use my AMI in Beijing region: **ami-f036e99d** (CoreOS-stable-1688.5.3-hvm) 



### Install Kops and Kubectl client on your laptop

- [install kops](https://github.com/kubernetes/kops/blob/master/docs/aws.md#install-kops)
- [install kubectl](https://github.com/kubernetes/kops/blob/master/docs/aws.md#install-kubectl)

### Create a proxy server with gost in AWS N. Virginia Region

click the button to create a proxy server with [gost](https://github.com/ginuerzh/gost) on AWS Fargate in us-east-1

![cloudformation-launch-stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=gost-service&templateURL=https://s3-us-west-2.amazonaws.com/pahud-cfn-us-west-2/kops-bjs/cloudformation/ecs-fargate-gost-tls-ss.yaml)



### Create a proxy forwarder in AWS Beijing Region

click the button below to create an internal http_proxy forwarder for your Kops cluster. This template will create a t2.micro EC2 in your existing VPC as the proxy forwarder.

![cloudformation-launch-stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.amazonaws.cn/cloudformation/home?region=cn-north-1#/stacks/new?stackName=kops-proxy&templateURL=https://s3.cn-north-1.amazonaws.com.cn/kops-bjs/cloudformation/bjs.yml)

### Create the cluster with Kops

update `create_cluster.sh` and modify the variables:

```
cluster_name='cluster.k8s.local'
ami='ami-f036e99d'
vpcid='vpc-c1e040a5'  
```

**cluster_name** : specify your cluster name, you can leave it as default.

**ami** : The AMI ID you just created and register in Beijing Region.

**vpcid**: Your existing VPC ID, in which you would launch your Kubernetes cluster with Kops.



execute the script to create the cluster:

```
$ bash create_cluster.sh 
```



















