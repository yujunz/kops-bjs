#!/bin/bash

source env.config
kops delete cluster --name cluster.bjs.k8s.local --yes
