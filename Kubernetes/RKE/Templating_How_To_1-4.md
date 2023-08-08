## Overview
- [Deploying an application](#deploying-an-application)
  - [Step 1 - Revert Server 1 to the baseline snapshot](#step-1---revert-server-1-to-the-baseline-snapshot)
  - [Step 2 - Log in to Server 1](#step-2---log-in-to-server-1)
  - [Step 3 - Install RKE2](#step-3---install-rke2)
  - [Step 4 - Create a namespace resource](#step-4---create-a-namespace-resource)
  - [Step 5 - Create a deployment resource](#step-5---create-a-deployment-resource)
  - [Step 6 - Create a service resource](#step-6---create-a-service-resource)
  - [Step 7 - Verify application connectivity](#step-7---verify-application-connectivity)
- [Install Helm and kubectl on student laptop](#install-helm-and-kubectl-on-student-laptop)
  - [Step 1 - Installing Helm on student laptop](#step-1---installing-helm-on-student-laptop)
  - [Step 2 - Install kubectl on student laptop](#step-2---install-kubectl-on-student-laptop)
- [Creating a Helm Chart](#creating-a-helm-chart)
  - [Step 1 - Stay on your student laptop](#step-1---stay-on-your-student-laptop)
  - [Step 2 - Build a helm chart](#step-2---build-a-helm-chart)
  - [Step 3 - Build a deployment template](#step-3---build-a-deployment-template)
  - [Step 4 - Create the service template](#step-4---create-the-service-template)
  - [Step 5 - Install using helm](#step-5---install-using-helm)
  - [Step 6 - Uninstall using helm](#step-6---uninstall-using-helm)

# Deploying an application

## Step 1 - Revert Server 1 to the baseline snapshot

## Step 2 - Log in to Server 1

## Step 3 - Install RKE2

Install RKE2 and kube-vip using the script created in previous labs

## Step 4 - Create a namespace resource

In this example, we will create a namespace, deployment, and service for the application we created with Docker at the beginning of Mod 4

Create a manifest file for the namespace:

```bash
vim apache-namespace.yaml
```

Add the following

**Be sure to fill in your own student information**

```bash
apiVersion: v1
kind: Namespace
metadata:
  name: apache-stud<student-number>
```

Apply the manifest file

```bash
kubectl apply -f apache-namespace.yaml
```

Ensure the namespace has been created:

```bash
kubectl get namespace
```

## Step 5 - Create a deployment resource

Create a manifest file for the deployment

```bash
vim apache-deployment.yaml
```

Add the following to the file:

**Be sure to fill in your own student information**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-stud<student-number>
  namespace: apache-stud<student-number>
spec:
  replicas: 1
  selector:
    matchLabels:
      name: apache-stud<student-number>
  template:
    metadata:
      labels:
        name: apache-stud<student-number>
    spec:
      containers:
      - name: apache-stud<student-number>
        image: orko/apache-server:<tag-with-stud-number>
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
```

Apply the manifest file

```bash
kubectl apply -f apache-deployment.yaml
```

Ensure the deployment has been created:

```bash
kubectl get deployment -n apache-stud<student-number>
```

## Step 6 - Create a service resource

Because we have installed kube-vip on our cluster we can create a service which will use the kube-vip load-balancer to set a virtual IP address for our application.

Create a manifest file for a service using the load-balancer

```bash
vim apache-service.yaml
```

Add the following:

**Be sure to fill in your own student information**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: apache-stud<student-number>-lb
  namespace: apache-stud<student-number>
spec:
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    name: apache-stud<student-number>
  type: LoadBalancer
```

Apply the manifest file

```bash
kubectl apply -f apache-service.yaml
```

Ensure the service has been created:

```bash
kubectl get service -n apache-stud<student-number>
```

This should show an IP address which was assigned by Kube-VIP within the range we assigned to kube-vip with a configmap when we installed it.

This IP address is the IP you will use to access the UI for your application in a browser.

## Step 7 - Verify application connectivity

If all resources have been successfully deployed, you will be able to reach the application in your browser at <http://<apache-ip>>

# Install Helm and kubectl on student laptop

## Step 1 - Installing Helm on student laptop

Follow the instructions here to install helm on your student laptop

- [https://github.com/helm/helm#install](https://github.com/helm/helm#install)

## Step 2 - Install kubectl on student laptop

Follow the instructions here to install `kubectl` with chocolatey

- [https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#install-on-windows-using-chocolatey-or-scoopl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#install-on-windows-using-chocolatey-or-scoop)
- Steps 3-6 will be done as your student user on you laptop **NOT ADMINISTRATOR** (Use your gitbash terminal in vscode)
- Step 6 tells you to configure kubectl to use a remote cluster
  - Each time you deploy kubernetes a cluster with RKE2, the contents for this config file can be found in `/etc/rancher/rke2/rke2.yaml`
  - Copy the contents of this file and change the server IP address from `https://127.0.0.1:6443` to `https://<server-ip>:6443`
  - **YOU WILL NEED TO FIND THE NEW CONTENTS OF THIS FILE EACH TIME YOU REDEPLOY RKE2**

Verify kubectl using the instructions here using the config file from your rke2-cluster

- [https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#verify-kubectl-configuration](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#verify-kubectl-configuration)
- You can now manage your kubernetes cluster from your dev laptop.
  - View your node and the pods running in your cluster with `kubectl get nodes` and `kubectl get pods -A`

# Creating a Helm Chart

Helm lets you create templated resources for Kubernetes.  This means you can expose information in your manifest files which can change between clusters, as variables.

## Step 1 - Stay on your student laptop

Open a terminal on your dev laptop

## Step 2 - Build a helm chart

A helm chart is a collection of resources such as services, deployments, ingresses, etc., which at a minimum needs a `Chart.yaml` and a `templates` directory. We will also be using a `values.yaml` file to specify values in our resources.

Create a `helm-charts` directory:

```shell
mkdir ~/helm-charts
```

Create a directory for the apache application we are creating a helm chart for

```shell
cd helm-charts

mkdir stud<student-number>-apache
```

Create the templates directory and Chart.yaml

```shell
cd stud<student-number>-apache/

mkdir templates
touch Chart.yaml
touch values.yaml
```

The helm-charts directory should look like this:

```shell
helm-charts/
      studX-apache/
          templates/
          Chart.yaml
          values.yaml
```

Add the following to the `Chart.yaml`

```shell
name: stud<student-number>-apache
version: 1.0.0
```

The `templates/` directory will contain all the resources needed for deploying our application.

Create a resource for your namespace, deployment, and service.

```shell
cd templates

touch apache-deployment.yaml
touch apache-service.yaml
```

The file structure should now look like this:

```shell
helm-charts/
      studX-apache/
          templates/
              apache-deployment.yaml
              apache-service.yaml
          Chart.yaml
          values.yaml
```

Fill in the apache-deployment.yaml and apache-service.yaml with the same contents from the application we deployed in templating Lab_01:

>**NOTE** We will not be using a namespace yaml because we will be creating it using other methods when we deploy our Helm Chart

apache-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-stud<student-number>
  namespace: apache-stud<student-number>
spec:
  replicas: 1
  selector:
    matchLabels:
      name: apache-stud<student-number>
  template:
    metadata:
      labels:
        name: apache-stud<student-number>
    spec:
      containers:
      - name: apache-stud<student-number>
        image: https://harbor.vip.ark1.soroc.mil/<stud-number>/apache-server:<tag-with-stud-number>
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
```

apache-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: apache-stud<student-number>-lb
  namespace: apache-stud<student-number>
spec:
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    name: apache-stud<student-number>
  type: LoadBalancer
```

In the templating Lab_01 we created a deployment which will work in a specific namespace with a specific image.  If we wanted to change values for any of the resources, we would have to change it in every resource manifest file.  Helm will do this for us based on what we specify in our `values.yaml`file as long as we add the variables to our helm chart templates.

Add the following to the `values.yaml` file

```yaml
metadata:
  name: apache-stud<student-number>
  namespace: apache-stud<student-number
spec:
  containers:
    image: https://harbor.vip.ark1.soroc.mil/<stud-number>/apache-server:<tag-with-stud-number>
```

Variables which are provided in the `values.yaml` are accessible from the `.Values` object in the template.  

For example if we wanted to use the name of our application specified in our `values.yaml` we would write it as follows

```yaml
{{ .Values.metadata.name }}
```

## Step 3 - Build a deployment template

Open the apache-deployment.yaml and change the name, namespace, and container image to refer to the `values.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.metadata.name }}
  namespace: {{ .Values.metadata.namespace }}
spec:
  replicas: 1
  selector:
    matchLabels:
      name: {{ .Values.metadata.name }}
  template:
    metadata:
      labels:
        name: {{ .Values.metadata.name }}
    spec:
      containers:
      - name: {{ .Values.metadata.name }}
        image: {{ .Values.spec.containers.image }}
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
```

## Step 4 - Create the service template

Repeat the same process from step 3 for the apache-service.yaml

- Create variables like we did in Step 3 for the following information:
  - `name:`
  - `namespace:`

## Step 5 - Install using helm

Ensure your kube-config file is correct and allows you to access your clusters

```shell
kubectl get nodes
```

Delete the resources you created in templating Lab 01 if they still exist

```shell
kubectl delete deployment -n apache-stud<student-number> apache-stud<student-number>
kubectl delete service -n apache-stud<student-number> apache-stud<student-number>-lb
kubectl delete namespace apache-stud<student-number>
```

Move to the base directory of your helm chart

```shell
cd ~/helm-charts/stud<student-number>-apache/
```

Create the Namespace with kubectl:

```shell
kubectl create ns apache-stud<student-number>
```

Run install the helm chart

**THIS WILL INSTALL THE HELM CHART ON THE CLUSTER YOUR KUBECONFIG IS CONFIGURED FOR**

```shell
helm install apache-stud4 .
```

Check the kubernetes cluster to make sure your app has been deployed

Check the namespace:

```shell
kubectl get namespace
```

Check the deployment:

```shell
kubectl get pods -n apache-stud<student-number>
```

Check the service and get the IP address assigned by kube-vip:

```shell
kubectl get svc -n apache-stud<student-number>
```

You can also view the helm project with helm

```shelll
helm ls
```

## Step 6 - Uninstall using helm

The helm chart can be unistalled with

```shell
helm uninstall <release name shown in the previous command>
```

Then delete the Namespace:
**We still need to delete the namespace using kubectl since we created it using kubectl**

```shell
kubectl delete ns apache-stud<student-number>
```