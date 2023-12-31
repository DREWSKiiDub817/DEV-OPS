# Preparing Air-gapped installation files for RKE2

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

## Step 4 - Update GitLab

1. Commit your changes to Gitlab for the new files we added to the rke2-directory

2. Create a new wiki page for RKE2 using the link we created earlier

- Add the following to the rke2 page:

    ```shell
    ## Overview
    - [Manual Install](#manual-install)
        - [Pulling Dependencies](#pulling-dependencies)
        - []()
    - [Automated Install](#automated-install)
        - []()
    - [Troubleshooting](#troubleshooting)


    # Manual install
    > NOTES
    #

    ## Pulling Dependencies
    > NOTES
    #

    # Automated install
    > NOTES
    #

    # Troubleshooting
    > NOTES
    #
    ```


