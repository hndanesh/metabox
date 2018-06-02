## What is metabox

Metabox is an enhancement API layer on top of Packer/Vagrant tools to simplify machine image builds and Vagrant VMs management. It hides low-level details of Packer/Vagrant offering a consistent workflow to create, author and manage images and virtual machine.

While Packer and Vagrant are amazing tools, crafting an end-to-end workflow to build and test images, and then run many virtual machines at scale of dozens might be a significant challenge. Initially, we built metabox while working on SPMeta2 project in order to automate SharePoint 2013/2016 deployments across Windows 2012, 2012 R2, 2016 using SQL 2012, 2014, 2016 and then deploying various versions of Visual Studio on top: 2013, 2015 and 2017.

At glance, here is what metabox glues together Packer/Vagrant and offers additional features on top:

YAML documents as authoring and management experience:
* YAML documents to define Packer builds and Vagrant VMs (!!!)
* YAML documents parametrization (either via ENV variables or by re-using other YAML values)

Enhanced markup on top of Packer/Vagrant markup:
* YAML markup gets translates into Packer JSON or Vagrant VM setup
* Custom YAML sections simplifies complexity of default Packer/Vagrant setups

Built-in file download capabilities:
* YAML document to define which files to download and where to place them
* pre/post download hooks (so you can zip/archive files)
* SHA1 checksum checks to avoid re-downloading 

Built-in "VM stack" concept, simplifies network and host name management:
* Vagrant VMs are always come together as a "stack"
* "stack" has got its own, dedicated IP range (so you don't have to deal with network at all)
* Metabox manages VM's IP address within stack
* Metabox manages VM host name within stack
* So you can spin up the same domain controllers within two different stack (network ranges)

Built-in support for Packer images:
* Win2012 platform:
  * Win2012 SOE (standard operation system)
  * Win2012 + SharePoint 2013 RTM 

* Win2012 R2 platform:
  * Win2012 R2 SOE (standard operation system)
  * Win2012 R2 + SharePoint 2013 SP1

* Win2016 platform:
  * Win2016 SOE (standard operation system)
  * Win2016 + SharePoint 2016 RTM?

Built-in support for Vagrant VMs:
* DC role - domain controller VM
* client role - a VM joined to DC
* SQL role - a VM joined to DC + SQL 2012, 2014 or 2016
* SharePoint role - a VM joined to DC + SP2013/SP2016

Altogether, metabox offers an end-to-end workflow to build SharePoint environments at scale, under fully automated manner which can be run under CI/CD pipelines.

## Tech overview
metabox itself is a Ruby based application. The following technology stack is used to get all things up and running:

* Ruby - metabox is written in Ruby 
* Rake - metabox exposes a bunch of Rake tasks
* Packer/Vagrant - metabox orchestrates Packer/Vagrant 
* Docker - metabox is developed under a Docker container 

While it may seem crazy, this technology stack allows metabox to work under various platforms. Here is what we tested so far:
* Windows 2008
* Windows 10
* MacOS 

Furthermore, Packer/Vagrant provision is done using the following tech:
* bash scripts / serverspec (for metabox Jenkins2 CI)
* PowerShell, Pester
* PowerShell DSC (various configurations for DC, SQL, SharePoint DSC)
* Ruby Sinatra (to expose files via HTTP server to Vagrant VMs)



