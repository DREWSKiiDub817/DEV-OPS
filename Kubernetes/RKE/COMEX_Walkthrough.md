# **COMEX Automated Installation Walkthrough**

## **Create Server1 Virtual Machine on your ESXi host**

1. Log into your ESXi host at `10.10.41.7`
2. Click `Virtual Machine`, then `Create / Register VM`
3. Click `Next`, enter `stud7-s1` in the `name` field.
4. Change `Guest OS family` to `Linux`
5. Change `Guest OS version` to `Rocky Linux (64-bit)`
6. Click `Next` at `Select storage`
7. Change the following to below:
   * CPU: `4`
   * RAM: `8GB`
   * Disk: `100GB`
   * Expand `Hard disk 1`, select `Thin provisioned`
8. Change `Network Adapter 1` to `VM Network`
9. Change `CD/DVD Drive 1` to `Datastore ISO file`:
    * At the pop up `Datastore browser` select:
      * `ISOs`, `Rocky Linux`, `Rocky-8.6-x86_64-dvd1.iso`
      * Click `SELECT`, `NEXT`, `FINISH`
10. Power VM on and select `Install Rocky Linux...`
11. At `WELCOME TO ROCKY LINUX 8` chose `English`, click `Continue`
12. Click `Installation Destination`, then click `Done`
13. Click `Installation Source`, then click `Done`
14. Click `Software Selection`:
    * Under `Base Environment` select `Server`
    * Under `Additional software for Selected Environment` select:
      * `Network File System Client`
      * `Development Tools`
      * `Headless Management`
      * `RPM Development Tools`
      * `System Tools`
      * Click `Done`
15. Click `Network & Host Name` and configure below:
    * Change `Host Name` to `stud7-s1` and click `Apply`
    * Click `Configure`, click `IPv6 Settings`, ensure `Disabled` selected
    * click `IPv4 Settings`
      * Change `Method` to `Manual`
      * Click `Add` and enter `172.16.7.51`, `255.255.255.0`, `172.16.7.254`
      * In `DNS servers` enter `10.10.44.50`
      * Click `Save`
16. Ensure to toggle `Ethernet (ens34)` radio button `ON`
17. Click `Root Password` under `USER SETTINGS`
    * Set password `P@ssw0rd`, click `Done` twice
18. Click `User Creation` and create `stud7`
    * Ensure `Make this user administrator` is selected
    * Set password `P@ssw0rd`, click `Done` twice

19. Click `Begin Installation` and wait
20. Once complete, click `Reboot`

## **Create Agent1 Virtual Machine on your ESXi host**
Follow the same step as Server1 build with the following changes
  *  CPU: `4`
  *  RAM: `8`
  *  Disk1: `100 GB`
  *  Disk2: `100 GB`
  *  IP: `172.16.7.52`
  *  Hostname: `stud7-a1`

## **Generate SSH Key**
1. On student laptop open git bash and navigate to `.ssh/`
2. Run `ssh-keygen -t rsa -b 2048`
3. Don't enter passphrase, just press `Enter` three times
4. Run `ssh-copyid -i ~/.ssh/id_rsa.pub root@172.16.7.51`
   * Enter password and type `yes` if prompted
5. Run `ssh-copyid -i ~/.ssh/id_rsa.pub root@172.16.7.52`
   * Enter password and type `yes` if prompted

## *Once server and agent VM's are up and running with SSH key*
## **Install RKE2 for container orchastration**
Open git bash and navigate to `/Desktop/Mod_6/Kube/stud7-kube/stud7-kube/`
1. Run `scp -r rke2-stud-7.tar.gz root@172.16.7.51:/home/stud7/`  

Log into `stud7-s1` and `cd /home/stud7`
1. Run `tar xzvf rke2-stud-7.tar.gz -C /usr/lib/` 
2. Run `./usr/lib/rke2/scripts/rke2-install.sh`
   * The `rke2-install.sh` script will initiate and complete the following:
     * Prep `stud7-s1` for RKE2 install
     * Install RKE2 on `stud7-s1` as master node
     * Install Kube-Vip on `stud7-s1`
     * Generate SSH Key and push to `stud7-a1` authorized_key file
     * Prep `stud7-a1` for RKE2 install
     * Install RKE2 on `stud7-a1` as worker node
     * Create a Persistent Volume for Longhorn on `stud7-a1`
     * Run `kubectl get nodes` on `stud7-s1` to verify both nodes are in the `Ready` status 
3. Add Cluster to Rancher
   * Log into rancher `https://rancher.vip.ark1.soroc.mil`  
   * Under `Cluster Management` click, `Import Existing`
   * Select `Generic`
   * Enter `stud7` under `Cluster Name` and click `Create`
   * Copy the second cmd, starts with `curl --insecure -sfl ...` and paste into `stud7-s1` terminal, press `enter`
     * **Note:** *This may take a few minutes*
4. Install Longhorn  
   * In Rancher, select `stud7` under `EXPLORE CLUSTER`
   * Click `Apps`, then `Charts` find `Longhorn`, click `Install`
   * Click `Next`, then under `Longhorn Default Settings` ensure the following:
     * Check box next to `Customize Default Settings`
     * Check box next to `Create Default Disk on Labeled Nodes`
     * Change `Default Replica Count` to `1`
     * Click `Install`
     * **Note:** *You may have to run `systemctl restart rke2-agent.server` on `stud7-a1` if Longhorn doesn't show both nodes*
5. Add Harbor Repository to Cluster in Rancher 
   * wtihin your `stud7` cluster in rancher, under `Apps` select `Repositories`
   * Click `Create`, name it `harbor`
   * For Target Index URL enter `https://harbor.vip.ark1.soroc.mil/chartrepo/stud7`
     * You will get a `certificate signed` error, dont fret, I got you
   * Click the ellipses  `3 dots` next to the repo you just added
     * select `Edit YAML` and enter `insecureSkipTLSVerify: true` under `spec:`, it shoud look like the following
      ```yaml
         spec:
            insecureSkipTLSVerify: true
            clientSecret: null
            url: https://harbor.vip.ark1.soroc.mil/chartrepo/stud7
      ```
   * Click `Save`
6. Install Django-app/studybud
   * On `stud7-s1` terminal, run `kubectl create ns django-ns` to create the namespace
   * In Rancher, select `stud7` under `EXPLORE CLUSTER`
   * Click `Apps`, then `Charts` find `django`, click `Install`
   * Ensure `django-ns` is selected under `Namespace`
   * Name it `studybud`, click `Next`, click `Install`
   * **Note:** *Run `watch kubectl get all -n django-ns` to watch the pod come up*
7. Verify you can reach your application via http link
   * In Rancher, select `stud7` under `EXPLORE CLUSTER`
   * Click `Apps`, then `Service Discovery`,then `Services`
   * Click the `http` link under `Target` next the `django`
   * If a new tab opens with `StudyBuddy` application, you have successfully deployed and application within the kubernetes cluster
  <br>
  <br>
  <br>
## *"MONEY DUDE!!!"*