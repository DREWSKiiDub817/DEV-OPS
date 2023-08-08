## Step 1 - Build VMs

Because we are in a learning environment, we will be using VMs for deploying RKE2 using the following configuration

- 1 Server Node
- 1 Agent Node

Using `Rocky 8.4` build 2 VMs using the guide from the `Mod 1 Linux Lab 01` (Steps below)

- Below is all the additional information you will need to build the VMs and install RKE2 throughout this Module

"X" indicates first, second, etc. IP address assigned from Range

# Server 1
- CPU: 4
- RAM: 8
- Disk: 100 GB
- IP: X.X.X.51
- Hostname: stud<student-number>-s1

# Agent 1
- CPU: 4
- RAM: 8
- Disk: 100 GB
- IP: X.X.X.52
- Hostname: stud<student-number>-a1

# Cluster Variables
- Domain: `stud7.soroc.mil`
- VIP IP: X.X.X.50
- VIP Hostname: vip
- VIP Range: X.X.X.54-X.X.X.59
- coredns IP: X.X.X.53
- Upstream DNS: 10.10.44.50 (Use this one for DNS when building VMs)
- Harbor Hostname: harbor.vip.ark1.soroc.mil
- Rancher Hostname: rancher.vip.ark1.soroc.mil

#

## Step 1 - Log in to your ESXi host

- Open a web browser.
- Navigate to the webpage of the ESXi host you were assigned by the instructors.
- Login to the ESXi host with your student username and password.
- You should be logged into the ESXi host and see it's main page displayed in your web browser.

#### Step 2 - Open the new virtual machine configuration menu

- If the `Navigator` tab is not open, click on the `Navigator` tab on the left side of the ESXi webpage.
- In the `Navigator` tab, click on `Virtual Machines`.
- In the `Virtual Machines` window, click on `Create / Register VM`.
  > A box will pop up to create your virtual machine.

#### Step 3 - Select a creation type

- Click on `Select a creation type`.
- In the `Select a creation type` menu, click on `Create a new virtual machine`.
- Click `Next` in the lower right corner.

#### Step 4 - Configure a name and guest OS

- Enter `<student username>_<node>` for the name of the VM.
- In the `Compatibility` drop-down leave the selection the default, which should match the version of ESXi you are using.
- In the `Guest OS family` drop-down, select `Linux`.
- In the `Guest OS version` drop-down, select `Rocky Linux (64-bit)`.
- Click `Next` in the lower right corner.

#### Step 5 - Select your storage

- Select the storage labeled with your student number using the format `ESXIxx_DS`.
- Click `Next` in the lower right corner.

#### Step 6 - Customize hardware

- In the `CPU` drop-down, select `4`.
- In `Memory`, enter `4096 MB`.
- In `Hard disk 1`, enter `50 GB`.
- Expand the Hard disk 1, in the Disk Provisioning section select the radio button for `Thin provisioned`.
- In the `Network Adapter 1` drop-down change the Network adapter 1 to  `VM Network` selected and check the `"Connect"` box.
- In the `CD/DVD Drive 1` drop-down, click `Datastore ISO file`.
- In the `Datastore browser` window, click on `ISOs`, open the Rocky Linux folder, click the .iso file `Rocky-8-6-x86_64-dvd1.iso`, and click `Select` in the bottom right.
- Ensure the `"Connect"` box next to the `Datastore ISO file` is checked.
- Click `Next` in the lower right corner.
- Click `Finish` in the lower right corner.
  > You should be returned to the Virtual Machines window.

### Task 2 - Installing Rocky Linux 8 from the UI

#### Step 1 - Accessing the VM's UI

- In the `Virtual Machines` window right-click on the VM that you just created.
- In the drop-down menu, select `Power` and `Power on`.
  > The VM should power on in a few minutes.
- In the `Virtual Machines` window right-click on the VM that you just created.
- In the drop-down menu, select `Console` and `Open browser console`.
- Select "Install Rocky Linux 8" and press enter.
- On the "WELCOME TO ROCKY LINUX 8.", Select English and click `Continue'.

#### Step 2 - Configure the `Installation Destination`

- In the `Installation Summary` page, click on `Installation Destination`.
- Select `Custom` for Storage Configuration.
- Click the blue `Done` button.
- On the `Manual Partioning` page, click `Click here to create them automatically`.
- We will leave them default for now but read the NOTES below for examples of when you would customize the configuration here.

- Click the blue `Done` button.
- In the `Summary of changes` window, click `Accept Changes`.
  > You should be returned to the `Installation Summary` page.

#### Step 3 - Configure the `Network & Host Name`

- In the `Installation Summary` page, click on `Network & Host Name`.
- Enter `<student username>-<node>` as the hostname in the `Host Name` block in the bottom left.
- Select the interface you would like to configure in the column on the left half of the window.
- Select `Configure` in the bottom right.
- Select the `IPv4 Settings` tab.
- In the `IPv4 Settings` tab, change the Method to `Manual`.
- In the `IPv4 Settings` tab, click the `Add button in the`Addresses block`.
- Enter the following data:
  - IPv4 address: 172.16.<student#>.10
  - Network mask: 255.255.255.0
  - Gateway: 172.16.<student#>.254
  - DNS: 10.200.99.30 & 31
  - Leave `Search domains` blank
- Move to the `IPv6 Settings` tab and change the method to `Disabled`.
- Now Click the `Save` button to save the settings.
- Change the switch at the top right from `off` to `on`.
- Click the blue `Done` button.

#### Step 5 - Configure the `Software Selection`

- In the `Installation Summary` page, click on `Software Selection`.
- For your **Base Environment** select `Server`.
- In the section: **Additional software for Selected Environment** Select:
  - Network File System Client
  - Development Tools
  - Headless Management
  - RPM Development Tools
  - System Tools
  > You may not use everything on this list, but at a minimum, having these tools installed should be able to give you everything you need on the server to do dev work on the fly or troubleshoot any sort of issues in an Air-Gapped environment.
- Click the blue `Done` button.

#### Step 6 - Configure the `Security Policy`

- In the `Installation Summary` page, click on `Security Policy`.
- Scroll all the way to the bottom of the list of security Policies, and select the option named **DISA STIG for Red Hat Enterprise Linux 8**.
- Click on `Select Profile`.
  > Pay attention to the errors which show up in the box at the bottom.
- `REMOVE` the security policy by toggling the switch at the top labeled `Apply security policy`, to `OFF`.
  > We will `NOT` be using the DISA STIG for training.
- Click the blue `Done` button.

#### Step 7 - Configure the `Root Password`

- In the `Installation Summary` page, click on `Root Password`.
- Enter the Root password `P@ssw0rd` in the `Root Password` box.
- Re-enter the Root password `P@ssw0rd` in the `Confirm` box.
- Click the blue `Done` button.

#### Step 8 - Configure the `User Creation`

- In the `Installation Summary` page, click on `User Creation`.
- Enter your student username in the user's full name in the `Full name` box.
- Enter your student username in the user's name that will shows in the shell in the `User name` box.
- Check the box: `Make this user administrator`.
- Enter `P@ssw0rd` in the user's password in the `Password` box.
- Re-enter `P@ssw0rd` in the user's password in the `Confirm password` box.
- Click the blue `Done` button.

#### Step 9 - Begin installation

- Click `Begin Installation` in the bottom right corner.
  > Then installation will take about 5-10 minutes.
- When the installation is complete, you will see a prompt to reboot.
- Click the Blue `Reboot System` to reboot the VM.
- When your VM has successfully rebooted, move on to the next Task.

