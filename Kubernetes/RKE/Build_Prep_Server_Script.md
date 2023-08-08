# **Prep Server Build**

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

4. Run a Ubuntu container

- To find your current directory type:

```shell
pwd
```

```shell
docker run -it -v <current-directory>:/mnt ubuntu:latest
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
scp -r rke2-stud-7.tar.gz root@172.16.7.51:/home/stud7/
```

## Step 8 - Unpack the script

You have already moved installation to your server. Now we will unpack it and run it on the server.

#

**ssh into your server node**

You should now see the tar gz file in your /home/<username>/ directory

```bash
cd /home/<username>/
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
tar xzvf rke2-stud-<student-number>.tar.gz -C /usr/lib/
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