#!/bin/bash

source env.config
kops delete cluster --name cluster.zhy.k8s.local --yes
