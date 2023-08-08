# **Application Lifecycle Management**
</br>

## *Rolling Updates and Rollbacks*
* kubecl rollout status deployment/myapp-deployment
* **Rolling update** is the default Deployment Strategy
* Updates and Rollbacks commands
    * **Create:** 
      * kubectl create -f deployment-definition.yml
    * **Get:** 
      * kubectl get deployments
    * **Update:** 
      * kubectl apply -f deployment-definition.yml
      * kubectl set image deployment/myapp-deployment nginx=nginx:1.9.1
    * **Status:**
      * kubectl rollout status deployment/myapp-deployment
      * kubectl rollout history deployment/myapp-deployment
    * **Rollback:**
      * kubectl rollout undo deployment/myapp-deployment

<br>

## *ENV Variables in Kubernetes*
* docker run -e APP_COLOR=pink simple-webapp-color
* kubectl edit pod \<pod_name>
  * set the Environment Varible to Green
    * Will fail because you cannot edit running pod but save changes to temp file for future creation
    * file located /tmp/\<edit.yml>
    * cat edit.yaml
    * **kubectl replace --force -f /tmp/edit.yaml**

<br>

* Plain Key Value
    ```Yaml
    env:
      - name: APP_COLOR
        value: pink
    ```
* ConfigMap

    ```Yaml
    env:
      - name: APP_COLOR
        valueFrom:
          configMapKeyRef:
    ```
* Secrets
  
    ```Yaml
    env:
      - name: APP_COLOR
        valueFrom:
          secretKeyRef:
    ```
<br>

## *Create Config Map*
* **Imperative**
  * kubectl create configmap
    * \<config-name> --from-literal=\<key>=\<value>
    * ie. app-config --from-literal=APP_COLOR=blue
* **Declarative**
  * kubectl create -f config-map.yaml

    ```Yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config
    data:
      APP_COLOR: blue
      APP_MODE: prod
    ```
<br>

## *Create Secrets*
* **Imperative**
  * kubectl create secret generic
    *  \<secret-name> --from-literal=\<key>=\<value>
    *  ie. app-secret --from-literal=DB_Host=mysql
* **Declarative**
  * kubectl create -f secret-data.yaml
  
  ```Yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: app-secret
    data:
      DB_Host: mysql
      DB_User: root
      DB_Password: paswrd
    ```
* **Encode Secrets**
  * echo -n 'mysql' | base64
  * echo -n 'root' | base64
  * echo -n 'paswrd' | base64
  ```Yaml
    DB_Host: bxlzcWw=
    DB_User: cm9vda==
    DB_Password: cGFzd3Jk
  ```
* **Decode Secrets**
  * echo -n 'bxlzcWw=' | base64 --decode
  * echo -n 'cm9vda==' | base64 --decode
  * echo -n 'cGFzd3Jk' | base64 --decode
  
* **Secrets in Pods**
  ```Yaml
    envFrom:
      - secretRef:
            name: app-secret
  ```
* Secrets are not Encrypted. Only encoded.
  * Do not check-in Secret objects to SCM along with code.
* Secrets are not encrypted in ETCD
  * Enable encryption at rest
* Anyone able to create pods/deployments in the same namespace can access the secrets
  * Configure least-privilege access to Secrets - RBAC
* Consider third-party secrets store providers
  * AWS Provider, Azure Provider, GCP Provider, Vault Provider
  
<br>

## *Encrypting Secret Data at Rest*

 