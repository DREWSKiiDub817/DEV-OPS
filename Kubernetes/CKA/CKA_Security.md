# **Security**
## *Kubernetes Security Primitives*
* **Authentication**
  * kubectl create serviceaccount sa1
  * kubectl get serviceaccount
* **Accounts**
  * All users are managed by the kube-apiserver
    * Static Password File
    1. Create a file with user details locally at **/tmp/users/user-details.csv**
        * ```txt
            # User File Contents
            password123,user1,u0001  
            password123,user2,u0002  
            password123,user3,u0003  
            password123,user4,u0004  
            password123,user5,u0005  
            ```
    2. Edit the kube-apiserver static pod configured by kubeadm to pass in the user details. The file is located at **/etc/kubernetes/manifests/kube-apiserver.yaml**
        * ```yaml
            apiVersion: v1
            kind: Pod
            metadata:
                name: kube-apiserver
                namespace: kube-system
            spec:
                containers:
                - command:
                    - kube-apiserver
                        <content-hidden>
                    image: k8s.gcr.io/kube-apiserver-amd64:v1.11.3
                    name: kube-apiserver
                    volumeMounts:
                    - mountPath: /tmp/users
                        name: usr-details
                        readOnly: true
                volumes:
                - hostPath:
                    path: /tmp/users
                    type: DirectoryOrCreate
                name: usr-details
          ```
    3. Modify the kube-apiserver startup options to include the basic-auth file
        * ``` yaml
           apiVersion: v1
            kind: Pod
            metadata:
                creationTimestamp: null
                name: kube-apiserver
                namespace: kube-system
            spec:
                containers:
                - command:
                    - kube-apiserver
                    - --authorization-mode=Node,RBAC
                        <content-hidden>
                    - --basic-auth-file=/tmp/users/user-details.csv 
          ```

    * Static Token File
    * Certificate

<br>

## *TLS in Kubernetes - Cert Creation*

* **Generate Keys**
    * openssl genrsa -out ca.key 2048
* **Certificate Signing Request**
    * openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
* **Sign Certificates**
  * openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt
* **Kube API Server**
  * openssl req -new -key apiserver.key -subj \ "/CN=kube-apiserver" -out apiserver.csr
  * In the openssl.cnf file, add the all the alternate names:
  * ```cnf
    [req]
    req_extensions = v3_req
    distinguished_name = req_destinguished_name
    [v3_req]
    basicConstraints = CA:FALSE
    keyUsage = nonRepudiation,
    subjectAltName = @alt_names
    [alt_names]
    DNS.1 = kubernetes
    DNS.2 = kubernetes.default
    DNS.3 = kubernetes.default.svc
    DNS.4 = kubernetes.default.svc.cluster.local
    IP.1 = 10.96.0.1
    IP.2 = 172.17.0.87
    ```
## *Lab*
cat /etc/kubernetes/manifests/kube-apiserver.yaml

## *Security Context*
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
spec:
  containers:
        - name: ubuntu
          image: ubuntu
          command: ["sleep","3600"]
          securityContext:
            runAsUser: 1000
            capabilities:
                add: ["MAC_ADMIN"]
```

## *Network Policy*
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy

spec:
  podSelector:
    matchLabels:
      role: db

  policyTypes:
  - Ingress
  - Egress

  ingress:
  - from:
    - podSelector:
        matchLabels:
          name: api-pod
      namespaceSelector:
        matchLabels:
            name: prod

    - ipBlock:
        cidr: 192.168.5.10/32

    ports:
    - protocol: TCP
      port: 3306

  egress:
  - to:
    - ipBlock:
        cidr: 192.168.5.10/32
    ports:
    - protocol: TCP
      port: 80
```
## *Notes*
Solutions that Support Network Policies:
* Kube-router
* Calico
* Romana
* Weave-net
Solutions that DO NOT Support Network Policies:
* Flannel

## *Lab*
* kubectl get networkpolicy
* 