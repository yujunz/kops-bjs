# Fast Bootstrapping with Local mirror

This is an enhancement from this request([#2](https://github.com/pahud/kops-bjs/issues/2)) that leverages all possible local mirror with minimal downloads from other global regions.

The enchancements including:

1. china can't access gcr.io docker repo but can leverage [this](https://anjia0532.github.io/2017/11/15/gcr-io-image-mirror/) from docker hub and use [docker china mirror](https://www.docker-cn.com/registry-mirror) for acceleration.
2. some artifacts from google cloud storage can be mirrored to S3 in Beijing region and set `--kubernetes-version` to specify the local S3 mirror path for acceleration
3. export `CNI_VERSION_URL` env variable and point to Beijing S3 for CNI plug-in download acceleration
4. use [official CoreOS AMI](https://coreos.com/os/docs/latest/booting-on-ec2.html) from Beijing region - no need to bake the AMI from other region and ship to Beijing region.
5. plus the `http_proxy` and `https_proxy`  for other requirement



## Usage

1. update your [env.config](https://github.com/pahud/kops-bjs/blob/master/scripts/env.config)

2. update your [proxy.yaml](https://github.com/pahud/kops-bjs/blob/master/scripts/proxy.yaml) and set your http_proxy host correctly

3. update your [create clusgter script](https://github.com/pahud/kops-bjs/blob/master/scripts/create_cluster_localmirror.sh), set your `vpcid` correctly and make sure `--ssh-public-key` points to your local SSH public key path.

4. run the create script:

   ```bash
   $ bash create_cluster_localmirror.sh
   ```

   You will see message like this, please ignore it, as we are using an alternative `--kubernetes-version` specified in the `kops create cluster` and kops will consider this as an older version.

   ```


   *********************************************************************************

   A new kubernetes version is available: 1.9.3
   Upgrading is recommended (try kops upgrade cluster)

   More information: https://github.com/kubernetes/kops/blob/master/permalinks/upgrade_k8s.md#1.9.3

   *********************************************************************************
   ```

   ​

5. edit your cluster

   ```bash
   $ kops edit cluster cluster.bjs.k8s.local
   ```

   and paste the content from `proxy.yaml` under the `spec` attribute. Make sure you set the `http_proxy` hostname correctly. 

   For example:

   ```
   # Please edit the object below. Lines beginning with a '#' will be ignored,
   # and an empty file will abort the edit. If an error occurs while saving this file will be
   # reopened with the relevant failures.
   #
   apiVersion: kops/v1alpha2
   kind: Cluster
   metadata:
     creationTimestamp: 2018-05-07T12:26:21Z
     name: cluster.bjs.k8s.local
   spec:
     hooks:
     - name: update-engine.service
       disabled: true
     etcdClusters:
       events:
         image: anjia0532/etcd:2.2.1
       main:
         image: anjia0532/etcd:2.2.1
     masterKubelet:
       podInfraContainerImage: anjia0532/pause-amd64:3.0
     kubeControllerManager:
       image: anjia0532/kube-controller-manager:v1.9.3
     kubeScheduler:
       image: anjia0532/kube-scheduler:v1.9.3
     kubeProxy:
       image: anjia0532/kube-proxy:v1.9.3
     kubeAPIServer:
       image: anjia0532/kube-apiserver:v1.9.3
     docker:
       logDriver: ""
       registryMirrors:
           - https://registry.docker-cn.com
     egressProxy:
       httpProxy:
         host: <your_http_proxy_host>
         port: 8888
       excludes: amazonaws.com.cn,amazonaws.cn,aliyun.cn,aliyuncs.com,registry.docker-cn.com
   [...]
   ```

6. Finally, update your cluster with `—yes`

   ```
   $ kops update cluster cluster.bjs.k8s.local --yes
   ```



## Debug

You may ssh into any master node with `ssh core@xxx.xxx.xxx.xxx` and type `journalctl -f` as root to see the system messages.

When all the three master nodes under ELB become healthy, you may access your cluster with `kubectl`.



