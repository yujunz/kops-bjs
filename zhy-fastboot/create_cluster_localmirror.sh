#!/bin/bash

source env.config

cluster_name='cluster.zhy.k8s.local'

# official CoreOS AMI
ami='ami-e7958185'

# change this to your vpcid
vpcid='vpc-bb3e99d2'

KUBERNETES_VERSION='v1.9.3'
kubernetesVersion="https://s3.cn-north-1.amazonaws.com.cn/kubernetes-release/release/$KUBERNETES_VERSION"

export CNI_VERSION_URL="https://s3.cn-north-1.amazonaws.com.cn/kubernetes-release/network-plugins/cni-plugins-amd64-v0.6.0.tgz"
export CNI_ASSET_HASH_STRING="d595d3ded6499a64e8dac02466e2f5f2ce257c9f"

kops create cluster \
     --name=${cluster_name} \
     --image=${ami} \
     --zones=cn-northwest-1a,cn-northwest-1b,cn-northwest-1c \
     --master-count=3 \
     --master-size="t2.medium" \
     --node-count=2 \
     --node-size="t2.medium"  \
     --vpc=${vpcid} \
     --kubernetes-version="$kubernetesVersion" \
     --ssh-public-key="~/.ssh/id_rsa.pub"
