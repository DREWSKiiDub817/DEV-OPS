# GitLab Runner

## What is GitLab Runner
- used in GitLab (CI)
  - Open source continuous integration service included with GitLab
- Used to run jobs & send results back to GitLab
- Pipeline jobs are assigned to available GitLab Runners
- The program can be install on your local machine, a VM, a Docker container and  cloud infrastructure

## GitLab Runner Types
   - Shared
     - Available to all projects in a GitLab instance
   - Group
     - Available to all projects in a group
   - Project
     - For a single project or a set of projects with specific requirements

## GitLab Runner Executor
   - the GitLab Runner executor determines the environment in which a job will run
      - In a VM via a hypervisor such as VirtualBox
      - Shell
      - Remote SSH
      - Docker

## Steps to start using GitLab Runner
   - https://docs.gitlab.com/runner/
   - https://docs.gitlab.com/runner/install/index.html
1. Install GitLab Runner
   
    ```bash
    cd C:/GitLab-Runner
    ./gitlab-runner.exe install -n <name>
    ```

2. Register GitLab Runner
   - (process to bind runner with gitlab instance)
    ```bash
    cd C:/GitLab-Runner
    ./gitlab-runner.exe register
    ```
     - Enter your GitLab instance URL 'https://jcugitlab/'
     - Enter the token you obtained to register the runner
     - Enter a description for the runner
     - Enter the tags associated with the runner, separated by commas.
     - Enter any optional maintenance notes for the runner
     - Provide the runner executor 'shell'

3. Start GitLab Runner
   ```bash
   cd C:/GitLab-Runner
   ./gitlab-runner.exe start
   ```