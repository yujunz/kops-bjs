#!/bin/bash

source env.config

cluster_name='cluster.bjs.k8s.local'

# official CoreOS AMI
#ami='ami-39ee3154'
ami='ami-555a8438'


# change this to your vpcid
vpcid='vpc-c1e040a5'

KUBERNETES_VERSION='v1.9.6'
KOPS_VERSION='1.9.1'
kubernetesVersion="https://s3.cn-north-1.amazonaws.com.cn/kubernetes-release/release/$KUBERNETES_VERSION"

export CNI_VERSION_URL="https://s3.cn-north-1.amazonaws.com.cn/kubernetes-release/network-plugins/cni-plugins-amd64-v0.6.0.tgz"
export CNI_ASSET_HASH_STRING="d595d3ded6499a64e8dac02466e2f5f2ce257c9f"
export KOPS_BASE_URL=https://s3.cn-north-1.amazonaws.com.cn/kubeupv2/kops/${KOPS_VERSION}/

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
