# **Logging & Monitoring**
</br>
  
## *Monitoring Solutions*
* Metrics Server
* Prometheus
* Elastic Stack
* Data Dog
* Dynatrace

</br>

## **Metric Server**
  * You can only have one per kubernetes cluster
  * Retreives metrics from each kubes nodes and pods
  * Stored in memory only 

## *Metric Server - Getting Started*
* minikue addons enable metrics-server
* git clone https://github.com/kubernetes-incubator/metrics-server
* kubectl create -f deploy/1.8+/
  * **View**
    * kubectl top node
    * kubectl top pod

</br>



  