# **Storage**

<br>

## *Docker Storage* 
* **Storage Drivers**
  * File System
    * /var/lib/docker
      * aufs
      * containers
      * image
      * volumes
* **Layered Architecture**
  ```Docker
  From Ubuntu

  RUN apt-get update && apt-get -y install python

  RUN pip install flask flask-mysql

  COPY . /opt/source-code

  ENTRYPOINT FLASK_APP=/opt/source-code/app.py flask run
  ```
    * docker build Dockerfile -t stud7/my-custom-app
<br>

      * Layer 1. Base Ubuntu Layer
      * Layer 2. Changes in apt packages
      * Layer 3. Changes in pip packages
      * Layer 4. Source code
      * Layer 5. Update Entrypoint
<br>
* **Volumes**
  * docker volume create data_volume
  * docker run -v data_volume:/var/lib/mysql mysql
  * docker run -v data_volume2:/var/lib/mysql mysql
  * docker run -v /data/mysql:/var/lib/mysql mysql
  * docker run \ --mount type=bind,source=/data/mysql,target=/var/lib/mysql mysql

<br>

* **Volumes**
* *Host storage*
```Yaml
volumes:
- name: data-volume
  hostPath:
    path: /data   #local host/node
    type: Directory
```
* *Pod Storage*
```Yaml
volumes:
- name: data-volume
  awsElasticBlockStore:
    volumeID: <volume-id>
    fsType: ext4
```
<br>

## *Persistent Volumes*

pv-definition.yaml
```Yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-volume1
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
      storage: 1Gi
  awsElasticBlockStore:
    volumeID: <volume-id>
    fsType: ext4
```
* kubectl create -f pv-definition.yaml
* kubectl get persistentvolume

<br>

## *Persistent Volume Claims*
pvc-definition.yaml
``` yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```
* kubectl create -f pvc-definition.yaml
* kubectl get persistentvolumeclaim

<br>

Delete PVCs
  * kubectl delete persistentvolumeclaim myclaim  

```yaml
persistentVolumeReclaimPolicy: Retain
persistentVolumeReclaimPolicy: Delete
persistentVolumeReclaimPolicy: Recycle
```
## *PVC in Pods*
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```
## *Static Provisioning*
* gcloud beta compute disks create \ --size 1GB --region us-east1 pd-disk

pv-definition.yaml
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-volume1
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 500Mi
  gcePersistentDisk:
    pdName: pd-disk
    fsType: ext4
```
## *Dynamic Provisioning*
* Create a **StorageClass**
sc-definition.yaml
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: google-storage
provisioner: kubernetes.io/gce-pd
```
* Inside the pvc-definition.yaml under accessModes:
  * ```yaml
    accessModes:
        - ReadWriteOnce
    storageClassName: google-storage
    ```


