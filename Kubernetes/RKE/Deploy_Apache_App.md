# Deploy Apache App in Rancher

## Step 1 - Log in to Rancher

## Step 2 - Install application

## * make sure to run the following command on your **server node** to create the namespace
```
kubectl create ns <name that you choose>
```

When we added our cluster to Rancher, we can manage the applications we install on our downstream clusters from Rancher.  

Rancher has a list of tested applications which can be installed from the `Apps` pane.

Later we will add our own helm chart repository to install applications but for now, we will use the ones included with Rancher.

1. On the left side of the page, select the `Apps` tab

2. In the `Charts` tab, you will see applications supported by Rancher

3. Find `Studx-apache` and select it

4. Select `Install` at the top right of the page

5. At the bottom left of the page, **check the box** for customizing install options and select `Next`.

6. Select the tab `Namespace you created above`
   
7. Name the application `whatever`



8. Edit the yaml file `name` & `namespace` to match what you created above

9. Click `install`

## Step 3 - Delete Application

Uninstalling an application which was installed through Rancher Apps is simple.

1. Under the `Apps` tab, select `Installed Apps`

2. Check the box to the left of your apache application

3. At the top, select `Delete`

# Once you have the pod up and running on your cluster type the following command to be able to see what external ip you will use to connect
```
kubectl get service -A
however you can use the following to access it internal to the cluster
172.16.7.51:<port of the Load balancer>
```