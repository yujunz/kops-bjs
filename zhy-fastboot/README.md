## fastboot for NinXia(cn-northwest-1) region

All scripts for Kops fast bootstrapping in NinXia(cn-northwest-1) region.



## Usage

1. follow the [README](https://github.com/pahud/kops-bjs/blob/master/README.md) to build the http_proxy tunnel between NinXia and US. You will need to create two cloudformation stacks - one in U.S. and the other in NinXia.

2. update your [env.config](https://github.com/pahud/kops-bjs/blob/master/zhy-fastboot/env.config)

3. update your [proxy.yaml](https://github.com/pahud/kops-bjs/blob/master/zhy-fastboot/proxy.yaml) and set your http_proxy host correctly

4. update your [create cluster script](https://github.com/pahud/kops-bjs/blob/master/zhy-fastboot/create_cluster_localmirror.sh), set your `vpcid` correctly and make sure `--ssh-public-key` points to your local SSH public key path.

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
   $ kops edit cluster cluster.zhy.k8s.local
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
    - instanceGroup: master-cn-northwest-1a
      name: a
    - instanceGroup: master-cn-northwest-1b
      name: b
    - instanceGroup: master-cn-northwest-1c
      name: c
    image: anjia0532/etcd:2.2.1
    name: main
  - etcdMembers:
    - instanceGroup: master-cn-northwest-1a
      name: a
    - instanceGroup: master-cn-northwest-1b
      name: b
    - instanceGroup: master-cn-northwest-1c
      name: c
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

(please note - replace the default **etcdClusters** privided  with your customized spec so Kops will bootstrap the etcd with your customized Docker image **anjia0532/etcd:2.2.1**, otherwise it will try pulling the image from `gcr.io` and this could take a long time. )

1. Finally, update your cluster with `—yes`

```
$ kops update cluster cluster.zhy.k8s.local --yes
```

Check the live walkthrough:

[![asciicast](https://asciinema.org/a/byqmH7x8tur7MP91gdqrrHsTf.png)](https://asciinema.org/a/byqmH7x8tur7MP91gdqrrHsTf)





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



## Beijing Region a.k.a. BJS Support(cn-north-1)

Yes, this script also supports AWS Beijing Region with 2 AZs. Please check the [sample scripts](https://github.com/pahud/kops-bjs/tree/master/bjs-fastboot).





