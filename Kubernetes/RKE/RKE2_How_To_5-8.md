## Overview
- [Automate the installation of RKE2](#automate-the-installation-of-rke2)
  - [Step 1 - Log into your student admin VM](#step-1---log-into-your-student-admin-vm)
  - [Step 2 - Checking kubernetes resources with kubectl](#step-2---checking-kubernetes-resources-with-kubectl)
- [](#)
  - [Step 2 - Build the `install_rke2` function](#step-2---build-the-install_rke2-function)
- [Connecting the cluster to a private repository](#connecting-the-cluster-to-a-private-repository)
- [](#-1)
  - [Step 1 - Revert server 1 to a snapshot](#step-1---revert-server-1-to-a-snapshot)
- [](#-2)
  - [Step 2 - Install RKE2](#step-2---install-rke2)
- [](#-3)
  - [Step 3 - Build `registries.yaml`](#step-3---build-registriesyaml)
  - [Step 4 - Restart the `rke2-server` service](#step-4---restart-the-rke2-server-service)
  - [Step 5 - Pull a test image](#step-5---pull-a-test-image)
- [Installing Kube-vip](#installing-kube-vip)
  - [Step 1 - Log into Server 1](#step-1---log-into-server-1)
- [](#-4)
  - [Step 2 - Verify cluster](#step-2---verify-cluster)
- [](#-5)
  - [Step 3 - Apply the manifest](#step-3---apply-the-manifest)
- [](#-6)
    - [Create the Kube-vip RBAC file](#create-the-kube-vip-rbac-file)
- [](#-7)
    - [Create the daemonset](#create-the-daemonset)
    - [Create the cloud controller](#create-the-cloud-controller)
- [](#-8)
  - [Step 4 - Verify installation](#step-4---verify-installation)
- [Automate the private repo and kube-vip install](#automate-the-private-repo-and-kube-vip-install)
  - [Step 1 - Add private repo to RKE2 installation](#step-1---add-private-repo-to-rke2-installation)
- [](#-9)
  - [Step 2 - Install Kube-vip](#step-2---install-kube-vip)

# Automate the installation of RKE2

## Step 1 - Log into your student admin VM

The following steps will be completed on your admin VM

## Step 2 - Checking kubernetes resources with kubectl

#

To check the status of a deployment, statefulset, or daemonset, you can run the following command:

```bash
kubectl -n <namespace> rollout status <container_type(deployment, statefulset, or daemonset)>.apps/<app_name>

example:
kubectl rollout status -n kube-system deployment.apps/rke2-coredns-rke2-coredns
```

This will return the rollout status of the deployment:

```bash
deployment "rke2-coredns-rke2-coredns" successfully rolled out
```

There is a problem with writing the command into our script though.  If the deployment is not yet deployed, the command will return a `non-zero` exit code and the script will stop.

We want to wait for the container to become ready before moving on without the script failing so we can create a `while loop`

We can use the `!` operator to only run the while loop when the value of the command returns a non-zero exit code

```bash
while ! kubectl -n <namespace> rollout status <container_type>.apps/<app_name>; do
    sleep 2 && echo "Waiting for <app-name> to come up"
done
```

Instead of writing this loop out every time we want to use it, we will create a function we can pass variables into:

```shell
check_container_status{
    while ! kubectl -n ${namespace} rollout status ${container_type}.apps/${app_name}; do
        sleep 2 && echo "Waiting for <app-name> to come up"
    done
}
```

This can be used in our **install_rke2** function by defining the variables when we call the **check_container_status** function

EXAMPLE:

```shell
app_name="rke2-coredns-rke2-coredns" namespace="kube-system" container_type="deployment" check_container_status
```

## Step 2 - Build the `install_rke2` function

In this lab you will automate the installation of RKE2

Your script must contain the following:

- a function named `install_rke2` contained in a file named `install_rke2.sh` in the source directory.
- Create a function named `check_container_status` in a file named `check_container_status.sh` in the source directory.
- Every action written into the script will have a comment explanation before the action
- Every action written into the script will print the succesfull completion of the action using `echo`
- The function `install_rke2` should contain the following actions:
  - Create the `config.yaml` with variables for the IPs and hostnames
  - run the install.sh script
  - enable and start the rke2-server.service
  - Call on the `check_container_status` function to perform a check on the following resources in the `kube-system` namespace:
    - daemonset.apps/rke2-canal
    - daemonset.apps/rke2-ingress-nginx-controller
    - deployment.apps/rke2-coredns-rke2-coredns
    - deployment.apps/rke2-coredns-rke2-coredns-autoscaler
    - deployment.apps/rke2-metrics-server
  - echo completion of the function

# Connecting the cluster to a private repository

#

## Step 1 - Revert server 1 to a snapshot

#

## Step 2 - Install RKE2

Use the script you built you have already built and tested to install RKE2

#

## Step 3 - Build `registries.yaml`

Create and open the `registries.yaml` file for editing

```bash
vim /etc/rancher/rke2/registries.yaml
```

Fill in the required information for you cluster and add the following to the file:

```yaml
mirrors:
  docker.io:
    endpoint:
      - "<harbor_hostname>.vip.<domain>"
  quay.io:
    endpoint:
      - "<harbor_hostname>.vip.<domain>"
  k8s.gcr.io:
    endpoint:
      - "<harbor_hostname>.vip.<domain>"
  "<harbor_hostname>.vip.<domain>":
    endpoint:
      - "<harbor_hostname>.vip.<domain>"
configs:
  "<harbor_hostname>.vip.<domain>":
    tls:
      insecure_skip_verify: true
```

What is being done here?

- mirrors such as `docker.io`, `quay.io`, etc. are aliases for public repositories to tell the RKE2 to pull from Harbor instead of the public repository.
- In configs, we are skipping the verification of the tls certificate

## Step 4 - Restart the `rke2-server` service

For these changes to take effect, the `rke2-server` service needs to be restarted.

> **NOTE** If there are multiple nodes in the cluster the **`registries.yaml` will need to be deployed on every node in the cluster.**

```bash
systemctl restart rke2-server
```

## Step 5 - Pull a test image

A test image named `orko/busybox:private-repo-test`has been loaded into harbor. Deploy a pod with a container using this image to ensure the cluster is pulling from the Harbor repository.

Create a manifest file to deploy a the busybox pod.

```bash
vim busybox-test.yaml
```

Add the following to the contents of the file.

**Change the image name and tag** to `busybox:private-repo-test`

We are telling busybox to print a statement with the `echo` command.  We will be able to view this in the logs once the pod has deployed.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  containers:
  - image: <image-name:image-tag>
    command:
      - echo
      - "busybox successfully deployed"
    imagePullPolicy: Always
    name: busybox
  restartPolicy: OnFailure
  ```

Apply the manifest file:

```bash
kubectl apply -f busybox-test.yaml
```

Make sure the pod was created.  The status should show complete.

**NOTE** This pod was deployed in the default namespace so we do not have to specify the namespace.

```bash
kubectl get pods
```

Check the logs of the pod to see the output of the command we had it run in the manifest file.

```bash
kubectl logs busybox
```

# Installing Kube-vip

One of the applications used for JCU Kubernetes clusters to improve the functionality of the platform, is Kube-vip. kube-vip provides Kubernetes clusters with a virtual IP and load balancer for both the control plane (for building a highly-available cluster) and Kubernetes Services of type LoadBalancer without relying on any external hardware or software.

## Step 1 - Log into Server 1

#

## Step 2 - Verify cluster

#

Ensure Lab 06 is completed and RKE2 is functioning on your server nodes.

## Step 3 - Apply the manifest

#

A manifest is a kubernetes resource in jaml or json format with a description of all the components of the resources being deployed.

RKE2 provides additional functionality allowing us to put files into the directory `/var/lib/rancher/rke2/server/manifests/` and RKE2 will automatically deploy the resources we put there.

### Create the Kube-vip RBAC file

#

Create the `kube-vip-rbac.yaml` and open for editing (This file will create the resources for the kube-vip ServiceAccount, ClusterRole, and ClusterRoleBinding):

```bash
vim /var/lib/rancher/rke2/server/manifests/kube-vip-rbac.yaml
```

Paste the following into the kube-vip-rbac.yaml file:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-vip
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  name: system:kube-vip-role
rules:
  - apiGroups: [""]
    resources: ["services", "services/status", "nodes"]
    verbs: ["list","get","watch", "update"]
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["list", "get", "watch", "update", "create"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: system:kube-vip-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-vip-role
subjects:
- kind: ServiceAccount
  name: kube-vip
  namespace: kube-system
```

### Create the daemonset

Next we will create the daemonset

```bash
vim /var/lib/rancher/rke2/server/manifests/kube-vip.yaml
```

Add the following to this file **BE SURE TO CHANGE VALUES SPECIFIC TO YOUR CLUSTER**

The name of the network interface you are using can be found using the nmtui, ip, or nmcli commands.  For example: `nmcli device status`

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  creationTimestamp: null
  name: kube-vip-ds
  namespace: kube-system
spec:
  selector:
    matchLabels:
      name: kube-vip-ds
  template:
    metadata:
      creationTimestamp: null
      labels:
        name: kube-vip-ds
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - <s1_hostname>
      containers:
      - args:
        - manager
        env:
        - name: vip_arp
          value: "false"
        - name: vip_interface
          value: lo
        - name: port
          value: "6443"
        - name: vip_cidr
          value: "32"
        - name: cp_enable
          value: "true"
        - name: cp_namespace
          value: kube-system
        - name: vip_ddns
          value: "false"
        - name: svc_enable
          value: "true"
        - name: vip_startleader
          value: "false"
        - name: vip_addpeerstolb
          value: "true"
        - name: vip_localpeer
          value: <s1_hostname>:<s1_ip>:10000
        - name: bgp_enable
          value: "true"
        - name: bgp_routerid
        - name: bgp_routerinterface
          value: "<network_interface>"
        - name: bgp_as
          value: "65000"
        - name: bgp_peeraddress
        - name: bgp_peerpass
        - name: bgp_peeras
          value: "65000"
        - name: bgp_peers
          value: <s1_ip>:65000::false
        - name: address
          value: <vip_ip>
        image: plndr/kube-vip:v0.3.5
        imagePullPolicy: Always
        name: kube-vip
        resources: {}
        securityContext:
          capabilities:
            add:
            - NET_ADMIN
            - NET_RAW
            - SYS_TIME
      hostNetwork: true
      nodeSelector:
        node-role.kubernetes.io/master: "true"
      serviceAccountName: kube-vip
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists
```

### Create the cloud controller

The cloud controller will act as a DHCP server for services with the type LoadBalancer

#

Next create the kube-vip cloud controller and all of it's resources:

```bash
vim /var/lib/rancher/rke2/server/manifests/kube-vip-cloud-controller.yaml
```

Add the following:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-vip-cloud-controller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  name: system:kube-vip-cloud-controller-role
rules:
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["get", "create", "update", "list", "put"]
  - apiGroups: [""]
    resources: ["configmaps", "endpoints","events","services/status", "leases"]
    verbs: ["*"]
  - apiGroups: [""]
    resources: ["nodes", "services"]
    verbs: ["list","get","watch","update"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: system:kube-vip-cloud-controller-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-vip-cloud-controller-role
subjects:
- kind: ServiceAccount
  name: kube-vip-cloud-controller
  namespace: kube-system
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kube-vip-cloud-provider
  namespace: kube-system
spec:
  serviceName: kube-vip-cloud-provider
  podManagementPolicy: OrderedReady
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: kube-vip
      component: kube-vip-cloud-provider
  template:
    metadata:
      labels:
        app: kube-vip
        component: kube-vip-cloud-provider
    spec:
      containers:
      - command:
        - /kube-vip-cloud-provider
        - --leader-elect-resource-name=kube-vip-cloud-controller
        image: kubevip/kube-vip-cloud-provider:0.1
        name: kube-vip-cloud-provider
        imagePullPolicy: Always
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      serviceAccountName: kube-vip-cloud-controller
```

The last resource we will create is a config map to give kube-vip a range of IP addresses to work with:

```bash
vim /var/lib/rancher/rke2/server/manifests/kube-vip-configmap.yaml
```

Add the following **CHANGE VALUES FOR YOUR CLUSTER**

```yaml
apiVersion: v1
data:
  range-global: <vip_ip_range>
kind: ConfigMap
metadata:
  annotations:
    provider: kubevip
  name: kubevip
  namespace: kube-system
```

## Step 4 - Verify installation

The kube-vip daemonset and cloud provider statefulset will be deployed in the kube-system namespace.  Verify both pods are deployed.

```bash
kubectl get pods -n kube-system
```

# Automate the private repo and kube-vip install

## Step 1 - Add private repo to RKE2 installation

In lab 06, the cluster was connected to an external repository after it was already started.  The `registries.yaml` can also be placed in the `/etc/rancher/rke2/` directory prior to the initial startup of the cluster.

#

Add the private repo to the `install_rke2` function

- The script must create the `registries.yaml` before starting the rke2-server service
  - Every action written into the script will have a comment explanation before the action
  - Every action written into the script will print the succesfull completion of the action using `echo`
  - the `registries.yaml` will have variables for the `Harbor hostname` and `domain`

## Step 2 - Install Kube-vip

Create a new function named `install_kube_vip` in a new file named `~/rke2/scripts/source/install_kube_vip.sh`

- Every action written into the script will have a comment explanation before the action
- Every action written into the script will print the succesfull completion of the action using `echo`
- Create all files nessecary for the installation of kube-vip
  - Create variables for all pieces of information you needed to change on the daemonset.
