#!/bin/bash

source env.config

cluster_name='cluster.bjs.k8s.local'

# official CoreOS AMI
ami='ami-39ee3154'

# change this to your vpcid
vpcid='vpc-c1e040a5'

KUBERNETES_VERSION='v1.9.3'
kubernetesVersion="https://s3.cn-north-1.amazonaws.com.cn/kubernetes-release/release/$KUBERNETES_VERSION"

export CNI_VERSION_URL="https://s3.cn-north-1.amazonaws.com.cn/kubernetes-release/network-plugins/cni-plugins-amd64-v0.6.0.tgz"

kops create cluster \
     --name=${cluster_name} \
     --image=${ami} \
     --zones=cn-north-1a,cn-north-1b \
     --master-count=3 \
     --master-size="m3.medium" \
     --node-count=2 \
     --node-size="m3.medium"  \
     --vpc=${vpcid} \
     --kubernetes-version="$kubernetesVersion" \
     --ssh-public-key="~/.ssh/id_rsa.pub"
