
## Overview
- [Manual install](#manual-install)
- [](#)
  - [Preparing Rocky 8.4 for RKE2 installation](#preparing-rocky-84-for-rke2-installation)
  - [Step 1 - Create a snapshot of the Server Node (s1)](#step-1---create-a-snapshot-of-the-server-node-s1)
  - [Step 2 - Log in to the Server Node](#step-2---log-in-to-the-server-node)
  - [Step 3 - CNI Configuration](#step-3---cni-configuration)
- [](#-1)
- [](#-2)
  - [Step 4 - Configure **/etc/hosts** file](#step-4---configure-etchosts-file)
- [](#-3)
  - [Step 5 - Add environment variables for the root user](#step-5---add-environment-variables-for-the-root-user)
- [](#-4)
  - [Step 6 - Set SELinux to Permissive](#step-6---set-selinux-to-permissive)
- [](#-5)
- [](#-6)
  - [Step 7 - Disable firewalld (Add firewalld rules later)](#step-7---disable-firewalld-add-firewalld-rules-later)
- [Pulling Dependencies](#pulling-dependencies)
- [](#-7)
  - [Preparing Air-gapped installation files for RKE2](#preparing-air-gapped-installation-files-for-rke2)
  - [Step 1 - Log in to your student laptop](#step-1---log-in-to-your-student-laptop)
  - [Step 2 - Prepare the the standard file structure](#step-2---prepare-the-the-standard-file-structure)
  - [Step 3 - Download the files](#step-3---download-the-files)
- [Automated install](#automated-install)
- [](#-8)
  - [Automate Everything](#automate-everything)
- [](#-9)
  - [Step 1 - Revert the Server Node to baseline](#step-1---revert-the-server-node-to-baseline)
- [](#-10)
  - [Step 2 - Log in to your student laptop](#step-2---log-in-to-your-student-laptop)
- [](#-11)
  - [Step 3 - Create the file structure](#step-3---create-the-file-structure)
- [](#-12)
  - [Step 4 - Build initiation script](#step-4---build-initiation-script)
- [](#-13)
  - [Step 5 - Build the `main.sh` script](#step-5---build-the-mainsh-script)
- [](#-14)
  - [Step 6 - Create the `prep_server` function](#step-6---create-the-prep_server-function)
- [](#-15)
  - [Prep Server Final](#prep-server-final)
  - [Adding variables](#adding-variables)
  - [Step 7 - Move the installation to the server](#step-7---move-the-installation-to-the-server)
- [](#-16)
  - [Step 8 - Unpack the script](#step-8---unpack-the-script)
- [](#-17)
  - [Step 9 - Run the script](#step-9---run-the-script)
  - [Step 10 - Watch the status](#step-10---watch-the-status)
- [Troubleshooting](#troubleshooting)
- [](#-18)
# Manual install
> NOTES
#
## Preparing Rocky 8.4 for RKE2 installation

## Step 1 - Create a snapshot of the Server Node (s1)

Create a snapshot of your server node virtual machine

## Step 2 - Log in to the Server Node

The following steps will be completed on the Server node VM

All of the configurations we will make to install RKE2 will be completed as the root user.

Change to the root user:

```shell
sudo su
```

## Step 3 - CNI Configuration

#

We will need to add the configuration settings for NetworkManager to allow the RKE2 cni(Container Network Interface)

#

Create a new file named **rke2-canal.conf** in NetworkManager's configuration directory

```shell
vim /etc/NetworkManager/conf.d/rke2-canal.conf
```

Add the following contents to the file

```shell
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:flannel*
```

Reload NetworkManager

```shell
systemctl reload NetworkManager
```

## Step 4 - Configure **/etc/hosts** file

#

Open the **/etc/hosts** file in your text editor

```shell
vim /etc/hosts
```

Add the hostnames and IPs for your cluster so they can be reached before DNS is configured

```shell
127.0.0.1   localhost
<Server1 IP> <Server1 hostname> <Server1 hostname>.<domain>
<VIP IP> <VIP hostname> <VIP hostname>.<domain>
```
Example
```
127.0.0.1 localhost
172.16.7.51 stud7-s1 stud7-s1.stud7.soroc.mil
10.10.44.50 vip vip.stud7.soroc.mil
```



## Step 5 - Add environment variables for the root user

#

Open the **/root/.bashrc** file with your text editor

```shell
vim /root/.bashrc
```

The following commands need to be added to the end of the **/root/.bashrc** file for management of the RKE2 cluster on the server node.

> **NOTE** You may also add any other aliases for the different ways you commonly mistype "kubectl"

```shell
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
alias ku=kubectl
alias kuebctl=kubectl
alias k=kubectl
```

Call the **/root/.bashrc** file to be the source for your current shell session

```shell
source /root/.bashrc
```

## Step 6 - Set SELinux to Permissive

#

There are still some issues with RKE2 running on RHEL8 with SELinux enabled so for the purposes of training, we will set this feature to permissive.

#

Open the SELinux config file for editing

```shell
vim /etc/selinux/config
```

Change 'enforcing' to 'permissive'

```shell
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```
Also set enforce to permissive:

```shell
setenforce permissive
```

## Step 7 - Disable firewalld (Add firewalld rules later)

For the purposes of training we will be disabling firewalld

```shell
systemctl disable firewalld --now
```
# Pulling Dependencies
> NOTES
# 

## Preparing Air-gapped installation files for RKE2

## Step 1 - Log in to your student laptop

__*All of the preparation for installation will be done on your student laptop*__

Move to the rke2 directory in your student kubernetes project you cloned to your laptop

```shell
cd ~/stud<student-number>-kubernetes/rke2/
```

This will be your working directory for deploying rke2

## Step 2 - Prepare the the standard file structure

The file structure for the beginning of the course will be as follows:

```shell
└── rke2
    └── scripts
        └── install
            ├── install.sh
            ├── rke2-images.linux-amd64.tar.zst
            ├── rke2.linux-amd64.tar.gz
            └── sha256sum-amd64.txt
```

We can create the directory structure using the `-p` option to also create all of the subdirectories.

```shell
mkdir -p rke2/scripts/install/
```

## Step 3 - Download the files

The shell script: `install.sh` may be used in an offline installation.  We will only need to set a couple variables to install RKE2 including systemd units.

The steps provided by Rancher may be found [here](https://docs.rke2.io/install/airgap/#rke2-installsh-script-install)

Navigate to the directory we created in Step 1

```shell
cd ~/stud<student-number>-kubernetes/rke2/scripts/install/
```

__NOTE__: The following downloads are for version 1.26.0 rke2 revision 2

```shell
curl -OLs https://github.com/rancher/rke2/releases/download/v1.26.0%2Brke2r1/rke2-images.linux-amd64.tar.zst

curl -OLs https://github.com/rancher/rke2/releases/download/v1.26.0%2Brke2r1/rke2.linux-amd64.tar.gz

curl -OLs https://github.com/rancher/rke2/releases/download/v1.26.0%2Brke2r1/sha256sum-amd64.txt

curl -sfL https://get.rke2.io --output install.sh
```

Check to make sure you have 4 files in `~/rke2/scripts/install/` directory.

```shell
[<studnumber> install]$ ll
total 832932
-rw-rw-r--. 1 dev dev     21047 May 30 11:30 install.sh
-rw-rw-r--. 1 dev dev 762982325 May 30 11:31 rke2-images.linux-amd64.tar.zst
-rw-rw-r--. 1 dev dev  89907802 May 30 11:28 rke2.linux-amd64.tar.gz
-rw-rw-r--. 1 dev dev      3626 May 30 11:28 sha256sum-amd64.txt
```
# Automated install
> NOTES
#
## Automate Everything

So far, we have only prepared the server downloaded the files needed for the installation of RKE2. These processes take time and you will be doing it many times.  Something which used to take you an hour can take only a few seconds when you have the processing power of a computer doing it for you.

#

## Step 1 - Revert the Server Node to baseline

I the first lab, you created a snapshot of the Server Node VM before anything was changed.  Revert back to that baseline snapshot before continuing with this lab

#

## Step 2 - Log in to your student laptop

All of the following steps will be completed on your student laptop

#

## Step 3 - Create the file structure

#

Create a directory to hold files you will source as environment variables on your server.

```shell
mkdir -p ~/<student-kubernetes-project>/rke2/scripts/source/
```

This directory will store environment variables for the cluster such as IP addresses, hostnames, functions, or whatever else you want to create a variable for.

Your file structure should look like the following:

```shell
rke2/
    scripts/
        source/
        install/
            rke2-images.linux-amd64.tar.zst
            rke2.linux-amd64.tar.gz
            sha256sum-amd64.txt
            install.sh
```

## Step 4 - Build initiation script

We will be creating an initiation script which will be calling the `main.sh` bash script which will be doing all the work.  This will be more important later on when we want the `main.sh` to run in the background but we want the initiation script to ask for credentials for ssh.

#

Add the following the initiation script:

```shell
vim ~/<student-project>/rke2/scripts/rke2-install.sh
```

The final initiation script will look like the following:

```shell
#!/bin/env bash

set -o errexit
set -o nounset
#set -o xtrace # Uncomment for verbose output

chmod +x /usr/lib/rke2/scripts/install/main.sh

/usr/lib/rke2/scripts/install/main.sh &
```

Save and exit the file.

Make the `rke2-install.sh` executable:

```shell
chmod +x ~/rke2/scripts/rke2-install.sh
```

## Step 5 - Build the `main.sh` script

The `main.sh` script will call the functions used for the preparation of the server and the installation of RKE2.

#

Create the main script and open it for editing:

```shell
vim ~/<student-project>/rke2/scripts/install/main.sh
```

Add the following to the `main.sh` file (notice how comments have been placed before every action):

```shell
#!/bin/env bash

set -o errexit
set -o nounset
# set -o xtrace # Uncomment for verbose output

# Redirects all standard output to the file /usr/lib/rke2/scripts/install.log
exec > /usr/lib/rke2/scripts/install.log 2>&1 

# sets the evironment variables source to all files in the source directory
source <(cat /usr/lib/rke2/scripts/source/*)

# Calls the function to prepare the server for the installation of RKE2
prep_server
```

## Step 6 - Create the `prep_server` function

The function `prep_server` is the function which will be used to prepare the server for the installation of RKE2

#

Create a function named `prep_server`

> ***NOTE*** Always leave a **space** at the end of a file or bash will see the last line as an unexpected termination of the file.

> ***NOTE*** Be sure to indent every new line in the function or it will not be read with the function and **ALWAYS LEAVE COMMENTS BEFORE A NEW ACTION**

##  Prep Server Final

```bash
prep_server () {
    set -o errexit
    set -o nounset
    # set -o xtrace # Uncomment for verbose output
# Create the NetworkManager cni configuration
    cat > /etc/NetworkManager/conf.d/rke2-canal.conf <<EOF
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:flannel*
EOF
    echo "Created NetworkManager cni configuration"

# Reload NetworkManager to apply the configuration
    systemctl reload NetworkManager
    echo "reloaded NetworkManager"

# Overwrite the current hosts file on the server
    cat > /etc/hosts <<EOF
127.0.0.1   localhost
${server1_ip} ${server1_hostname} ${server1_hostname}.${domain}
EOF
    echo "Configured /etc/hosts"

# Overwrite the selinux config file
    cat > /etc/selinux/config <<EOF
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
EOF
    echo "Configured the SELinux config file"

# Set the running SELinux config
    setenforce 0
    echo "Sucessfully set the running selinux config to Permissive"

# Disable and stop firewalld
    systemctl disable --now firewalld
    echo "Successfully stopped and disabled SELinux"

}
```

## Adding variables

If we ran the script right now, it would fail because it does not know the variables so we will create a variables file which will be sourced with the functions.

Create the variables file:

```shell
vim ~/rke2/scripts/source/variables
```

Add the following to your variables file:

We will also add the kubernetes environment variables to this file and it should look like this when you're done

```bash
# Variables for the cluster configuration
server1_ip=<server1-ip>
server1_hostname=<server1-hostname>
domain=orko.mil

# Environment variables for kubernetes
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
alias ku=kubectl
alias kuebctl=kubectl
alias k=kubectl
```

## Step 7 - Move the installation to the server

Everything which will be used to install of RKE2 will be in the `~/<student-project>/rke2` directory.  We will package this into a compressed archive and move it to our server.

#

> **NOTE** The docker run command used here will need to be run in either Command Prompt or Powershell because we will need to use the Windows filepath format to mount the container.

1. ## Open **Command Prompt**

2. Navigate to your student project folder

```shell
cd <student-project>
```

3. Find the filepath to your current directory

```shell
echo %cd%
```
or   
full path

example
```shell
/c/Users/stud7/Desktop/Mod_6/Kube/stud7-kube/stud7-kube
```

4. Run a Ubuntu container

- To find your current directory type:

```shell
pwd
```

```shell
docker run -it -v /c/Users/stud7/Desktop/Mod_6/Kube/stud7-kube/stud7-kube:/mnt ubuntu:latest
```

- The -v option creates a bind mount at the specified directory

    ```shell
    docker run -it -v <host-directory>:<directory-inside-container> <image-name>:<tag>
    ```

5. Package the rke2 directory into a compressed archive file.

Move to the directory where we mounted our student project

```shell
cd /mnt
```

Create the compressed archive file:

```shell
tar -czvf rke2-stud-7.tar.gz rke2/
```

6. Exit the container

```shell
exit
```

7. Return to your gitbash terminal
Copy the compressed archive file to your server:

```shell
scp rke2-stud-7.tar.gz root@172.16.7.51:/home/stud7/
```

## Step 8 - Unpack the script

You have already moved installation to your server. Now we will unpack it and run it on the server.

#

**ssh into your server node**

You should now see the tar gz file in your /home/stud7/ directory

```bash
cd /home/stud7/
```

List the directory contents:

```shell
ls -al
```

The installation of RKE2 reqiures root access so we will change to the root user to run the script.

```bash
sudo su
```

Unpack the compressed archive file to the `/usr/lib/` directory

```shell
tar xzvf rke2-stud-7.tar.gz -C /usr/lib/
```

## Step 9 - Run the script

```shell
/usr/lib/rke2/scripts/rke2-install.sh
```

## Step 10 - Watch the status

We wrote the script to output all standard out to a log file in the `/usr/lib/rke2/scripts/` directory.  The script will continuously write to this file.

To watch the output, tail the file

```shell
tail -f /usr/lib/rke2/scripts/install.log
```

# Troubleshooting
> NOTES
#
