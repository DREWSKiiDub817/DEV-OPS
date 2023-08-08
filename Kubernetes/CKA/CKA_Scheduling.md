# **Scheduling**
</br>

## *Taints & Tolerations*


```YAML
apiVersion:
kind: Pod
metadata:
    name: myapp-pod
sepc:
    containers:
    - name: nginx-container
      image: nginx

    tolerations:
    - key: "app"
      operator: "Equal"
      value: "blue"
      effect: "NoSchedule"
```
</br>

* kubectl describe node kubemaster | grep Taint
* kubectl taint node nod01 spray=mortein:NoSchedule  
* kubectl taint node nod01 spray=mortein:NoSchedule-
* kubectl label nodes node-1 size=Large

</br>

```YAML
apiVersion:
kind:
metadata:
  name: myapp-pod
spec:
  containers:
   - name: data-processor
     image: data-processor
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: size
            operator: In
            values:
            - Large
```
## *Node Affinity Types*
* **Available:**
  * requiredDuringSchedulingIgnoredDuringExecution
  * preferredDuringSchedulingIgnoredDuringExecution
* **Planned:**
  * requiredDuringSchedulingRequiredDuringExecution
  * preferredDuringSchedulingRequiredDuringExecution

## *Node Affinity Practice*
* kubectl describe node node01
* kubectl label --help (to see options for label command)
* kubectl label node node01 color= blue
* kubectl create deployment blue --image=nginx --replicas=3
* kubectl describe node node01 | grep Taints
* kubectl get nodes
* kubectl describe node controlplane | grep Taints
* kubectl edit deployment blue
  * edit document with correct keys:values
* kubectl get pods -o wide
* kubectl create deployment red --image=nginx --relpicas=2 --dry-run=client -o yaml
* kubectl create deployment red --image=nginx --relpicas=2 --dry-run=client -o yaml > red.yaml


``` Yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
    defaultRequest:
      memory: 256Mi
    type: Container
```
``` yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-limit-range
spec:
  limits:
  - default:
      cpu: 1
    defaultRequest:
      cpu: 0.5
    type: Container
```
A quick note on editing PODs and Deployments
Edit a POD
Remember, you CANNOT edit specifications of an existing POD other than the below.

spec.containers[*].image
spec.initContainers[*].image
spec.activeDeadlineSeconds
spec.tolerations
For example you cannot edit the environment variables, service accounts, resource limits (all of which we will discuss later) of a running pod. But if you really want to, you have 2 options:

1. Run the kubectl edit pod <pod name> command.  This will open the pod specification in an editor (vi editor). Then edit the required properties. When you try to save it, you will be denied. This is because you are attempting to edit a field on the pod that is not editable.

A copy of the file with your changes is saved in a temporary location as shown above.

You can then delete the existing pod by running the command:

kubectl delete pod webapp

Then create a new pod with your changes using the temporary file

kubectl create -f /tmp/kubectl-edit-ccvrq.yaml

2. The second option is to extract the pod definition in YAML format to a file using the command

kubectl get pod webapp -o yaml > my-new-pod.yaml

Then make the changes to the exported file using an editor (vi editor). Save the changes

vi my-new-pod.yaml

Then delete the existing pod

kubectl delete pod webapp

Then create a new pod with the edited file

kubectl create -f my-new-pod.yaml

Edit Deployments
With Deployments you can easily edit any field/property of the POD template. Since the pod template is a child of the deployment specification,  with every change the deployment will automatically delete and create a new pod with the new changes. So if you are asked to edit a property of a POD part of a deployment you may do that simply by running the command

kubectl edit deployment my-deployment

## *Daemon Sets*
**Daemon Sets** ensures one copy of the pod is always present in all nodes in the cluster
  * Monitoring Solutions
  * Logs Viewer
  * kube-proxy (worker node needed on every node)
  * Weave-net (Networking)

</br>

daemon-set-definition.yaml

``` yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-daemon
spec:
  selector:
    matchLabels:
      app: monitoring-agent
  template:
    metadata:
      labels:
        app: monitoring-agent
    spec:
      containers:
      - name: monitoring-agent
```
* kubectl create -f daemon-set-definition.yaml
* kubectl get daemonsets
* kubectl describe daemonsets monitoring-daemon

* kubectl get daemonsets -A
* kubectl describe daemonsets kube-proxy -n kube-system

## *Static Pods*
* The **kubelet** aka Captain of the host, can manage the node independently by putting pod.yaml files at **etc/kubernetes/manifests**
 * Under **kublete.service**
   * --pod-manifest-path=/etc/Kubernetes/manifests \\\

kubectl get pods -A
  * if it ends with a node name, i.e. kube-scheduler-**controlplane**, it is a **static pod**

kubectl get pod kube-scheduler-controlplane -n kube-system -o yaml
  * look for **ownerReferences:**
    ```Yaml
    kind: Node
    ```
https://github.com/kubernetes/community/blob/master/contributors/devel/sig-scheduling/scheduling_code_hierarchy_overview.md

https://kubernetes.io/blog/2017/03/advanced-scheduling-in-kubernetes/

https://jvns.ca/blog/2017/07/27/how-does-the-kubernetes-scheduler-work/

https://stackoverflow.com/questions/28857993/how-does-kubernetes-scheduler-work