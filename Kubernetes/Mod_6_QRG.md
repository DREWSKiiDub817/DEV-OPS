# **Mod 6 Quick Reference Guide**

## **File Paths**
```bash
# NetworkManager cni configuration
/etc/NetworkManager/conf.d/rke2-canal.conf

# NTP server
/etc/chrony.conf

# Hosts file
/etc/hosts

# Selinux config file
/etc/selinux/config

# RKE2 config.yaml
/etc/rancher/rke2/config.yaml

# Harbor Regitries.yaml
/etc/rancher/rke2/registries.yaml

# Scripts
/usr/lib/rke2/scripts/

# Install files
/usr/lib/rke2/scripts/install/

# Source files
/usr/lib/rke2/scripts/sources/

# Variables file
/usr/lib/rke2/scripts/source/variables

# Node-Token
/var/lib/rancher/rke2/server/node-token

# Kube-Vip files
/var/lib/rancher/rke2/server/manifests/kube-vip-rbac.yaml
/var/lib/rancher/rke2/server/manifests/kube-vip.yaml
/var/lib/rancher/rke2/server/manifests/kube-vip-cloud-controller.yaml
/var/lib/rancher/rke2/server/manifests/kube-vip-configmap.yaml

# Persistent Volume Claim
/var/lib/longhorn
```

## **Docker**
```bash
# Build Docker Image
docker build -t apache-server:v1 .

# Verify Image is in Docker Desktop
docker images | grep apache-server

# Run Container with Image Created
docker run -d -p 8080:80 --name=apache apache-server:v1

# Tag Image
docker tag <current-image-name-and-tag> <new-image-name-and-tag>
docker tag apache-server:v1 harbor.vip.ark1.soroc.mil/stud7/apache-server:v1

# Push Image
docker push <harbor-hostname>.<domain>/stud<student-number>/<image-name>:v1
docker push harbor.vip.ark1.soroc.mil/stud7/apache-server:v1

# Run Ubuntu Conatainer ****COMMAND PROMPT****
docker run -it -v /c/Users/stud7/Desktop/Mod_6/Kube/stud7-kubernetes:/mnt ubuntu:latest

# Create Compressed Archive file
tar -czvf rke2-stud-7.tar.gz rke2/

# Copy file to Server1 ****GITBASH****
scp -r rke2-stud-7.tar.gz root@172.16.7.51:/home/stud7/

# Uncompress the file on Server1 at /usr/lib/
tar xzvf rke2-stud-7.tar.gz -C /usr/lib/
```

## **Helm Chart**
```bash
# File structure
helm-charts/
      stud7-apache/
          templates/
              apache-deployment.yaml
              apache-service.yaml
          Chart.yaml
          values.yaml

# Install using Helm
kubectl delete deployment -n apache-stud7 apache-stud7
kubectl delete service -n apache-stud7 apache-stud7-lb
kubectl delete namespace apache-stud7
cd ~/helm-charts/stud7-apache/
kubectl create ns apache-stud7
helm install apache-stud4 .

# Installing using Helm Chart Manifest
helm package apache-stud7/

# Move file to Server1
scp <tgz-file> root@172.16.7.51:/home/stud7/

# Convert to base64
cat <file>.tar.gz | base64 -w 0 >> <name>-chart.yaml

# Copy files to manifests directory
cp apache-stud7-chart.yaml /var/lib/rancher/rke2/server/manifests/

# Delete if installed using Manifest
Remove the chart.yaml file from manifests/
kubectl delete addon apache-stud7-chart -n kube-system
kubectl delete helmchart -n apache-stud7 apache-stud7
kubectl delete ns apache-stud7
```

## **Kubectl**
```bash
kubectl get services        # List all services in the namespace
kubectl get pods --all-namespaces  # List all pods in all namespaces
kubectl get pods -o wide   # List all pods in the current namespace, with more details
kubectl get deployment my-dep   # List a particular deployment
kubectl get pods                # List all pods in the namespace
kubectl get pod my-pod -o yaml  # Get a pod's YAML

kubectl -n kube-system patch daemonset.apps/kube-vip-ds -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'

kubectl -n kube-system patch daemonset.apps/kube-vip-ds -p '{"spec": {"template": {"spec": {"nodeSelector": null}}}}'


kubectl create secret generic -h
kubectl create namespace <name> --dry-run=client -o yaml > <name>-namspace.yaml
kubectl create namespace test --dry-run=client -o yaml > test-namspace.yaml
kubectl describe <resource> <name> -n <namespace>

# Force delete
kubectl delete pod <PODNAME> --grace-period=0 --force --namespace <NAMESPACE>

# Get Secrets and Addons
k get secret -n kube-system
k get addon -n kube-system

# Kill RKE2 Services and Uninstall
rke2-killall.sh
rke2-uninstall.sh

# Check is script is running
ps aux | grep rke2-install.sh

# Restart Chronyd service
systemctl status chronyd.service

# Get all services
k get svc -A
```