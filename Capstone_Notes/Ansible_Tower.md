## What is Ansible Tower
<br>

- **Ansible Tower** a front end GUI for Ansible with an integrated database. Allows for Role-Based Access Control, Job scheduling, Playbook workflows, RESTful API, External logging integrations, and Real-time job status updates. Essentially Ansible Tower is a centralized point for all Ansible related entities.
<br>

## Ansible Job Template
<br>

- **Two Types**
  - **Job Template:** Single Job
  - **Workflow Template:** Multiple Jobs
<br>
<br>

- **Projects** - is a collection of playbook (yaml) usually stored in a repository like GitLab
- **Inventories** - is all the hostnames and IP's of the assests you want to manage
- **Credentials** - are used to connect to managed hosts/assests (*GitLab Token*)
- **Templates** - Ties everything together, similar to .gitlab-ci.yaml in a GitLab Project.

## Credentials
You will need to create two different creds:
- One for host connection via ssh
- One for repository to GitLab Project

## Inventory
- Name it
- Add Organization
- Inventory (*Group*) Variables in yaml file *Optional*
- Add Host
  - IP/Hostname.FQDN
  - Host Variables *Optional*

## Projects
- Defines a repository for all your Playbooks
  - Name
  - Organization
  - Source Control Credential Type: **Git**
  - Source Control URL: **Copy HTTPS URL of GitLab Project**
  - Branch: **Main or Master**
  - Select Source Control Credential: **Git Creditial added above**
  - Options: **Update Revision on Launch** (*Pulls latest playbook from GitLab Project Repo*)

## Template
- **IMPORTANT NOTE:** Limit:  *Only targets host defined within this field, not entire inventory*
- For Example:
  - **Inventory:** HostA, HostB, HostC, HostD
  - **Limit:** HostA, HostC, HostD

### Click here for  [Ansible Tower How-To](http://10.10.44.20/Stud7/stud7-capstone/-/wikis/AT_How_To)