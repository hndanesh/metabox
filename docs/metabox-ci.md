Metabox is an enhancement API layer on top of Packer/Vagrant tools to simplify machine image builds and Vagrant VMs management. It hides low-level details of Packer/Vagrant offering a consistent workflow to create, author and manage images and virtual machine.

This section describes CI/CD approach for automating metabox tasks and running Packer/Vagrant builds at scale. We assume that reader is familiar with concepts of CI/CD builds and blue/green deployments.

## Why to use CI?

Using metabox CLI, we can efficiently build Packer images and Vagrant VMs. CLI can be used by people to build local environments or can be easily integrated into CI/CD pipelines. However, as the amount of Packer images grows and so does the amount of various virtual machines, it's becoming exponentially hard to manage and work with. Metabox itself needs a way to run Packer builds and test virtual machines creation under automated, fully unattended way. 

That's where we provide a pre-setup, ready-to-use Jenkisn2 CI server. It comes with metabox, we use it to perform regression testing of the metabox itself before releasing new versions as well as to manage our internal infrastructure at scale. You can also use on your local laptop to manage your imaged and VMs working well with Windows/MacOS platforms.

Consider it as an example of how metabox can work together with your CI/CD pipelines to test and deliver infrastructure as a code for your local development or within a team.

## Prerequisites for Jenkins2 
First of all, make sure you get metabox working locally. Check out other sections of the documentation to get it up and running.

Next, there are two prerequisites which have to be installed before getting Jenkins2 on both Windows/MacOS:
* Java
* PowerShell

Java is needed to get Jenkins2 salves (CI agents) work. We also use PowerShell to automatically shutdown/startup Jenkins2 slave in a consistent way on both Windows/MacOS platforms. 

Depending on your platform, get both PowerShell and Java installed. Here are a few suggestions on how it can be done:

**Windows install**
```bash
choco install -y jre8
```

**MacOS install**
```bash
brew cask install java
brew cask install powershell
```

Make sure that both Java and PowerShell are in your PATH. Metabox and Jenkins2 slave will be using PATH to resolve these tools. Once done, you can progress with Jenkins2 virtual machine creation.

## Building Jenkins2 CI server VM
Metabox provides Jenkins2 server build via  via metabox document under `\documents\metabox_ci`. It consists of a few packer image resources and one vagrant stack:

* centos7-java8 packer image - CentOS7 + Java8 
* centos7-jenkins2 packer image - CentOS7 with pre-configured Jenkins2
* metabox-ci vagrant stack - two instances of Jenkins2 server

You don't have to change anything in these documents, they are already pre-setup and configured so let's build packer images following VM creation:

**Building packer images**
```bash
# build packer images
cls && "config/.metabox.ci.bat" && rake resource:generate && rake packer:build[centos7-mb-java8,--force] && rake vagrant:add[centos7-mb-java8,--force]
cls && "config/.metabox.ci.bat" && rake resource:generate && rake packer:build[centos7-mb-jenkins2,--force] && rake vagrant:add[centos7-mb-jenkins2,--force]"

# or with metabox 0.1.1
cls && "config/.metabox.ci.bat" && rake metabox:build_image[centos7-mb-java8,--force]"
cls && "config/.metabox.ci.bat" && rake metabox:build_image[centos7-mb-jenkins2,--force]"

```

Once done, you can progress and build Jenkins2 instance with pre-configured pipelines.

**Building Jenkins2 VMs**
```bash
# build Jenkins2 VM
cls && "config/.metabox.ci.bat" && rake resource:generate && rake vagrant:up[metabox-ci::jenkins2-beta]

# or with metabox 0.1.1
cls && "config/.metabox.ci.bat" && rake metabox:start_vm[metabox-ci::jenkins2-beta]

```

Once done, you should have fully configured Jenkins2 at `http://localhost:9080`. User metabox-metabox to get in.
While building Vagrant VM, metabox will also shutdown/start a new Jenkins2 agent so that you don't have to do anything to register slaves.

## Metabox Jenkins2 CI server in details
We use Jenkins2 to orchestrate Packer/Vagrant build using metabox CLI. Pretty much, this is our CI server to build images at scale, test new releases, manage our internal infrastructure. Here are some things you should know about how it all works.

Current installation requires 512Mb RAM and 2 CPUs so it is pretty safe to run it on a local laptop. In fact, we do this all the time. All configuration is defined in metabox document under `\documents\metabox_ci`. 

We suggest running it with `.metabox.ci.bat` or `.metabox.ci.sh` configuration files. That's how CI server and its agent get environment variables: metabox spins up Jenkins2 VM, then reloads agents passing environment variables which were previously sourced. That guarantees that both VM and agent has got the same environment variables. If you need your own configuration - put it under `congig.custom` folder and then re-run all the commands.

By default, metabox automatically registers a slave on the same host where Vagrant VM is run. That means that all Jenkins2 builds will be run on the same host, and hence, will have access to VirtualBox. Internally, all Jenkins2 pipelines still call metabox; we propagate metabox source location and other environment variables to the slave so that there is no difference between you running metabox from CLI or Jenkins2 running metabox from the pipelines. That ensures consistency between CLI usage by people and CI server.

## Metabox Jenkins2 CI pipelines
Out of the box, we provide various pipelines to build packer images and virtual machines. There are also a few utility pipelines. Here is how pipelines are organised:

* /metabox/core-pipelines
* /metabox/filesets
* /metabox/packer-images
* /metabox/vagrant-stacks

**core-pipelines** are internal pipelines, they house pipelines for regression testing for packer/vagrant builds.

**filesets** provide pipelines to execute file downloads. They use name convention "fileset+resource" to orchestrate file download based on the pipeline name. While executed, pipeline would resolve file resource via pipeline name and then run metabox `rake fileset_name:resource_name` with the corresponding values.

Name convention is used also for both packer/vagrant builds. Pipelines rely on their names to pass the right resource name to corresponding metabox tasks.

**packer-images** provide pipelines to execute Packer builds for various platforms. CentOS7, Windows 2012/R2 and Windows 2016. You can execute these either one by one, or use "-all" pipeline to get all images built. Name convention suggests that the pipeline name should correspond to a Packer resource name.

**vagrant-stacks** provide pipelines to execute Vagrant stack builds. Name convention is that top folder corresponds to a stack name, and then within every folder, there are pipelines to manage a particular VM by its name. Name convention is "/stack-name/action-vm_name". You can use these to stand up your VMs, one by one or with "-all" prefix; halt, destroy or up all of them. 

## Blue/green deployments and regression testing
You may have noticed that by default we provide two configuration files for creating a Jenkins2 server:
* config/.metabox.ci.bat
* config/.metabox.ci-dev.bat

These configuration specify different environment variables for Jenkins2: instance name, UI port and so on. In nutshell, `METABOX_JENKINS_INSTANCE_NAME` variable is propagated later into YAML document as a postfix for the Jenkins2 VM name. Simply saying, you can create as many Jenkins2 instances as you want to by creating different configuration files. We created two files to standup "beta" and "dev" instances of Jenkins2, and these are two physically different virtual machines.

Having the ability to stand up a new, isolated Jenkins2 server is crucial for blue/green deployments and regression testing. While most of the time we work on "beta" Jenkins2 instance, for development or regression testing we stand-up a new instance on "dev" (or other configuration) passing `METABOX_GIT_BRANCH` environment variable. This simple trick creates a completely new, isolated Jenkins2 instance and then propagates `METABOX_GIT_BRANCH` to all Packer/Vagrant builds. All resources which we define in metabox are now going to be built from scratch on a different branch. Metabox documents, most of the time, use `METABOX_GIT_BRANCH` environment variables so that all resources would have this prefix/postfix and hence will be physically different.

Using separate, physically different Jenkins2 instances with different `METABOX_GIT_BRANCH` is the way we can re-build all resources in an isolated environment without touching what was already created. Once testing is done, we can either change `METABOX_GIT_BRANCH` or pull the latest source code on other Jenkins2 instancies.  



 














