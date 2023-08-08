# **CKA Core Concepts**
</br>

## **Docker vs ContainerD**
## *CLI Utility*
* ContainerD
    * **ctr** comes with ContainerD - very limited
    * **nerdctl** -is better for ContainerD
    * nerdctl
    * nerdctl run --name redis redis:alpine
    * nerdctl run --name webserver -p 80:80 -d nginx
* Docker
    * **docker**
    * docker run --name redis redis:apline
    * docker run --name webserver -p 80:80 -d nginx
**crictl**
    - for CRI complatible container runtimes
     * RKT, ContainerD
    * crictl
    * crictl pull busybox
    * crictl images
    * crictl ps -a
    * crictl exec -i -t \<container_id> ls
    * crictl logs \<container_id>
    * crictl pods
## *docker vs crictl link*
 * https://kubernetes.io/docs/reference/tools/map-crictl-dockercli/

* https://github.com/kodekloudhub/certified-kubernetes-administrator-course

# *ETCD for Beginners*
**ETCD** is a distributed reliable key-value store that is Simple, Secure & Fast
    * **Key-Value store**
        * Tabular/Relational Databases
* Install ETCD
* To find out what version run
  * ./etcdctl --version
    * you should see etcdcrl version & API version
  * ETCDCTL v3
    * ./etcdctl put key1 value1
    * ./etcdctl get key1
# *Kube API Server*
    * **Kube-API Server** is repsonsible for:
      * Authenticate User
      * Validate Request
      * Retrieve data
      * Update ETCD
      * Schedular
      * Kubelet
## *PODs with YAML*
``` YAML
apiVersion: v1
kind: Pod
metadata:
    name: nginx
    labels:
        app: nginx
        tier: front-end
spec:
    containers:
    - name: nginx
      image: nginx
    - name: busybox
      image: busybox
```


``` YAML
apiVersion: v1
kind: ReplicationController
metadata:
    name: myapp-rc
    labels:
        app: myapp
        type: front-end
spec:
    template:
    
        metadata:
            name: myapp
            labels:
                app: myapp
                type: front-end
        spec:
            containers:
            - name: nginx-container
            image: nginx
    replicas: 3
```


``` Yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: myapp-replicaset
    labels:
        app: myapp
        type: front-end
spec:
    template:

        metadata:
            name: myapp-pod
            labels:
                app: myapp
                type: front-end
        spec:
            containers:
            - name: nginx-container
            image: nginx
    replicas: 3
    selector: 
        matchLabels:
            tier: front-end
```
``` Yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: myapp-replicaset
    labels:
        app: myapp
        type: front-end
spec:
    template:

        metadata:
            name: myapp-pod
            labels:
                app: myapp
                type: front-end
        spec:
            containers:
            - name: nginx-container
            image: nginx
    replicas: 3
    selector: 
        matchLabels:
            tier: front-end
```

``` YAML
apiVersion: v1
kind: Service
metadata:
    name: myapp-service
spec:
    type: NodePort
    ports:
    - targetPort: 80
      port: 80
      nodePort: 30008
    selector: 
        app: myapp
        type: front-end
```
``` YAML
apiVersion: v1
kind: Service
metadata:
    name: back-end
spec:
    type: ClusterIP
    ports:
    - targetPort: 80
      port: 80
    selector: 
        app: myapp
        type: back-end
```
kubectl create -f service-definition.yml
kubectl get service

kubectl replace -f relicaset-definition.yml
kubectl scale --replicas=6 -f replicaset-definition.yml
kubectl scale --replicas=6 replicaset myapp-replicaset

kubectl get replicaset
kubectl describe replicaset
kubectl get rs
kubectl get deployments



kubectl get pods
kubectl run nginx --image=nginx
kubectl describe pod newpods-<id>
kubectl describe pod webapp
kubectl delete pod webapp
kubectl run redis --image=redis123 --dry-run -o yaml
kubectl run redis --image=redis123 --dry-run -o yaml > redis.yaml
kubectl create -f redis.yaml
kubectl apply -f redis.yaml

kubectl get namespaces
kubectl get pods --namespace-research
kubectl run redis --image=redis -namespace=<name>
kubectl get ns
kubectl get pods --all-namespaces or -A


Create an NGINX Pod

* kubectl run nginx --image=nginx

Generate POD Manifest YAML file (-o yaml). Don’t create it(–dry-run)

* kubectl run nginx --image=nginx --dry-run=client -o yaml

Create a deployment

* kubectl create deployment --image=nginx nginx

Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run)

* kubectl create deployment --image=nginx nginx --dry-run=client -o yaml

Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file.

* kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml

Make necessary changes to the file (for example, adding more replicas) and then create the deployment.

* kubectl create -f nginx-deployment.yaml

OR

In k8s version 1.19+, we can specify the –replicas option to create a deployment with 4 replicas.

* kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml