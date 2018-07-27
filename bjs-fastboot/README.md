# Fast bootstrapping with local mirror

This is an enhancement from this request([#2](https://github.com/pahud/kops-bjs/issues/2)) that leverages all possible local mirror with minimal downloads from other global regions.

The enchancements including:

1. china can't access gcr.io docker repo but can leverage [this](https://anjia0532.github.io/2017/11/15/gcr-io-image-mirror/) from docker hub and use [docker china mirror](https://www.docker-cn.com/registry-mirror) for acceleration.
2. some artifacts from google cloud storage can be mirrored to S3 in Beijing region and set `--kubernetes-version` to specify the local S3 mirror path for acceleration
3. export `CNI_VERSION_URL` env variable and point to Beijing S3 for CNI plug-in download acceleration
4. use [official CoreOS AMI](https://coreos.com/os/docs/latest/booting-on-ec2.html) from Beijing region - no need to bake the AMI from other region and ship to Beijing region.
5. plus the `http_proxy` and `https_proxy`  for other requirement that can't leverage local mirror.



## Usage

1. follow the [README](https://github.com/pahud/kops-bjs/blob/master/README.md) to build the http_proxy tunnel between NinXia and US. You will need to create two cloudformation stacks - one in U.S. and the other in Beijing.

2. update your [env.config](https://github.com/pahud/kops-bjs/blob/master/bjs-fastboot/env.config)

2. update your [proxy.yaml](https://github.com/pahud/kops-bjs/blob/master/bjs-fastboot/proxy.yaml) and set your http_proxy host correctly

3. update your [create cluster script](https://github.com/pahud/kops-bjs/blob/master/bjs-fastboot/create_cluster_localmirror.sh), set your `vpcid` correctly and make sure `--ssh-public-key` points to your local SSH public key path.

5. run the create script:

   ```bash
   $ bash create_cluster_localmirror.sh
   ```

   You will see message like this, please ignore it, as we are using an alternative `--kubernetes-version` specified in the `kops create cluster` and kops will consider this as an older version.

   ```
   A new kubernetes version is available: 1.9.3

      Upgrading is recommended (try kops upgrade cluster)

      More information: https://github.com/kubernetes/kops/blob/master/permalinks/upgrade_k8s.md#1.9.3

   ```




5. edit your cluster

   ```bash
   $ kops edit cluster cluster.bjs.k8s.local
   ```

   and paste the content from `proxy.yaml` under the `spec` attribute. Make sure you set the `http_proxy` hostname correctly. 

   For example:

   ```
   spec:
     assets:
       fileRepository: https://s3.cn-north-1.amazonaws.com.cn/kops-bjs/fileRepository/
     hooks:
     - name: update-engine.service
       disabled: true
     etcdClusters:
     - etcdMembers:
       - instanceGroup: master-cn-north-1a-1
         name: a-1
       - instanceGroup: master-cn-north-1b-1
         name: b-1
       - instanceGroup: master-cn-north-1a-2
         name: a-2
       image: anjia0532/etcd:2.2.1
       name: main
     - etcdMembers:
       - instanceGroup: master-cn-north-1a-1
         name: a-1
       - instanceGroup: master-cn-north-1b-1
         name: b-1
       - instanceGroup: master-cn-north-1a-2
         name: a-2
       image: anjia0532/etcd:2.2.1
       name: events
     masterKubelet:
       podInfraContainerImage: anjia0532/pause-amd64:3.0
     kubeControllerManager:
       image: anjia0532/kube-controller-manager:v1.9.8
     kubeScheduler:
       image: anjia0532/kube-scheduler:v1.9.8
     kubeProxy:
       image: anjia0532/kube-proxy:v1.9.8
     kubeAPIServer:
       image: anjia0532/kube-apiserver:v1.9.8
     docker:
       logDriver: ""
       registryMirrors:
           - https://registry.docker-cn.com
     egressProxy:
       httpProxy:
         host: <host>
         port: 8888
       excludes: amazonaws.com.cn,amazonaws.cn,aliyun.cn,aliyuncs.com,registry.docker-cn.com
   ```

6. Finally, update your cluster with `—yes`

   ```
   $ kops update cluster cluster.bjs.k8s.local --yes
   ```



## Debug

You may ssh into any master node with `ssh core@IP_ADDRSS` and type `journalctl -f` as root to see the system messages.

```
ip-172-31-55-1 core # journalctl  -f
-- Logs begin at Mon 2018-05-07 14:12:03 UTC. --
May 07 14:12:47 ip-172-31-55-1.cn-north-1.compute.internal systemd[870]: Reached target Paths.
May 07 14:12:47 ip-172-31-55-1.cn-north-1.compute.internal systemd[870]: Reached target Sockets.
May 07 14:12:47 ip-172-31-55-1.cn-north-1.compute.internal systemd[870]: Reached target Timers.
May 07 14:12:47 ip-172-31-55-1.cn-north-1.compute.internal systemd[870]: Reached target Basic System.
May 07 14:12:47 ip-172-31-55-1.cn-north-1.compute.internal systemd[1]: Started User Manager for UID 500.
May 07 14:12:47 ip-172-31-55-1.cn-north-1.compute.internal systemd[870]: Reached target Default.
May 07 14:12:47 ip-172-31-55-1.cn-north-1.compute.internal systemd[870]: Startup finished in 39ms.
May 07 14:12:49 ip-172-31-55-1.cn-north-1.compute.internal sudo[884]:     core : TTY=pts/0 ; PWD=/home/core ; USER=root ; COMMAND=/bin/bash
May 07 14:12:49 ip-172-31-55-1.cn-north-1.compute.internal sudo[884]: pam_unix(sudo:session): session opened for user root by core(uid=0)
May 07 14:12:49 ip-172-31-55-1.cn-north-1.compute.internal sudo[884]: pam_systemd(sudo:session): Cannot create session: Already running in a session
May 07 14:13:10 ip-172-31-55-1.cn-north-1.compute.internal update_engine[725]: I0507 14:13:10.124577   725 update_attempter.cc:493] Updating boot flags...
```

(You should be able to see the message keeps flowing)



When all the three master nodes under `ELB` become healthy, you may access your cluster with `kubectl`. Typically it would take `5-8` minutes to become all healthy.



## NinXia Region a.k.a. ZHY Support(cn-northwest-1)

Yes, this script also supports AWS NinXia Region with 3 AZs. Please check the [sample scripts](https://github.com/pahud/kops-bjs/tree/master/zhy-fastboot).



