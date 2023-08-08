# **Troubleshooting**

## *Lab*
1. Look for pods in the alpha namespace
    * kubectl get pods -n alpha
2. Switch alpha namespace to default
   * k config set-context --current --namespace=alpha
   * k get pods (*alpha namespace should be default now and you down have to specify everytime you run a command*)
3. Check deployment webapp-mysql
   * kubectl get deploy
   * kubectl get svc

* curl http://localhost:30081
* k describe deploy webapp-mysql
  * DB_Host: mysql-service (correct)
* k get svc
  * mysql (incorrect, **mysql-service** is what it should be)

* alias k=kubectl
* kubectl describe replicaset \<name>
* k get pods -n kube-system
* cat /etc/kubernetes/manifests/
* kubectl get pods -n kube-system --watch
* k get deploy
* k describe deploy app
* k get pods -n kube-system 
* k logs kube-controller-manager-controlplane -n kube-system

* k get nodes
* k describe node \<name>
* top
* df -h
* service kubelet status
* sudo journalctl -u kubelet
* openssl x509 -in /var/lib/kubelet/\<node_name.crt> -text