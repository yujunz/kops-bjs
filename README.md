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

[![cloudformation-launch-stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=gost-service&templateURL=https://s3-us-west-2.amazonaws.com/pahud-cfn-us-west-2/kops-bjs/cloudformation/ecs-fargate-gost-tls-ss.yaml)



### Create a proxy forwarder in AWS Beijing Region

click the button below to create an internal http_proxy forwarder for your Kops cluster. This template will create a t2.micro EC2 in your existing VPC as the proxy forwarder.

[![cloudformation-launch-stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.amazonaws.cn/cloudformation/home?region=cn-north-1#/stacks/new?stackName=kops-proxy&templateURL=https://s3.cn-north-1.amazonaws.com.cn/kops-bjs/cloudformation/bjs.yml)

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



update `env.config`

```
export AWS_PROFILE='bjs'
export AWS_DEFAULT_REGION='cn-north-1'
export AWS_REGION=${AWS_DEFAULT_REGION}
export KOPS_STATE_STORE=s3://pahud-kops-state-store
```

1. **AWS_PROFILE** - make sure the profile name points to your AWS Beijing Region configuration. Check *~/.aws/config* for details.

2. **AWS_DEFAULT_REGION** - specify *cn-north-1* for Beijing Region.

3. **KOPS_STATE_STORE** - you need specify an empty S3 bucket for Kops state store, make sure you change the value and points to your S3 bucket in Beijing Region.

   ​

execute the script to create the cluster:

```
$ bash create_cluster.sh 
```

After a few minutes, you can validate the cluster like this:

```
$ kops validate cluster
Using cluster from kubectl context: cluster.k8s.local

Validating cluster cluster.k8s.local

INSTANCE GROUPS
NAME			ROLE	MACHINETYPE	MIN	MAX	SUBNETS
master-cn-north-1a-1	Master	m3.medium	1	1	cn-north-1a
master-cn-north-1a-2	Master	m3.medium	1	1	cn-north-1a
master-cn-north-1b-1	Master	m3.medium	1	1	cn-north-1b
nodes			Node	m3.medium	2	2	cn-north-1a,cn-north-1b

NODE STATUS
NAME						ROLE	READY
ip-172-31-41-211.cn-north-1.compute.internal	master	True
ip-172-31-43-233.cn-north-1.compute.internal	master	True
ip-172-31-62-125.cn-north-1.compute.internal	node	True
ip-172-31-73-124.cn-north-1.compute.internal	master	True
ip-172-31-85-213.cn-north-1.compute.internal	node	True

Your cluster cluster.k8s.local is ready
```

Or get nodes list like this

```
$ kubectl get nodes
NAME                                           STATUS    ROLES     AGE       VERSION
ip-172-31-41-211.cn-north-1.compute.internal   Ready     master    6m        v1.9.3
ip-172-31-43-233.cn-north-1.compute.internal   Ready     master    5m        v1.9.3
ip-172-31-62-125.cn-north-1.compute.internal   Ready     node      5m        v1.9.3
ip-172-31-73-124.cn-north-1.compute.internal   Ready     master    6m        v1.9.3
ip-172-31-85-213.cn-north-1.compute.internal   Ready     node      5m        v1.9.3
```



### clean up

delete the cluster

```
$ kops delete cluster --name cluster.k8s.local --yes
```

And delete the two cloudformation stacks from N.Virginia and Beijing regions.















