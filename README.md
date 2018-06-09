
# Metabox

Metabox is an enhancement API layer on top of Packer/Vagrant tools to simplify machine image builds and Vagrant VMs management. It hides low-level details of Packer/Vagrant offering a consistent, YAML-based workflow to describe, author and manage Packer images and Vagrant virtual machines.
 
Initially, metabox was developed by Aleksandr Sapozhkov (@shurick81) and Anton Vishnyakov (@avishnyakov). An early beta version of metabox was designed to provide disposable SharePoint environments for the SPMeta2 project late 2017.  A few month later, we pushed metabox further enabling automation of SharePoint 2013/2016 deployments with a consistent, repeatable and disposable workflow on Windows 2012, 2012 R2, 2016 using SQL 2012, 2014, 2016 and various versions of Visual Studio on top: 2013, 2015 and 2017.

## Metabox in details
At a glance,  metabox glues together Packer/Vagrant and offers additional features on top:

YAML documents as authoring and management experience:
* YAML documents to define Packer builds and Vagrant VMs (sick!)
* YAML documents parametrisation: either via ENV variables or by re-using other YAML values

The enhanced markup on top of Packer/Vagrant markup:
* YAML markup gets translates into Packer JSON or Vagrant VM setup
* Custom YAML sections simplifies complexity of default Packer/Vagrant setups

Built-in file download capabilities:
* YAML document to define which files to download and where to place them
* pre/post download hooks (so you can zip/archive files)
* SHA1 checksum checks to avoid re-downloading 

Built-in "VM stack" concept, simplified network and hostname management:
* Vagrant VMs are always come together as a "stack"
* "stack" has got its own, dedicated IP range so you don't have to deal with network at all
* Metabox manages VM's IP address within stack
* Metabox manages VM's hostnames within stack

Built-in support for Packer images:
* Win2012 platform:
  * Win2012 SOE (standard operation system)
  * Win2012 + SharePoint 2013 RTM 

* Win2012 R2 platform:
  * Win2012 R2 SOE (standard operation system)
  * Win2012 R2 + SharePoint 2013 SP1

* Win2016 platform:
  * Win2016 SOE (standard operation system)
  * Win2016 + SharePoint 2016 RTM (in progress)

Built-in support for Vagrant VMs:
* DC role - domain controller VM
* client role - a VM joined to DC
* SQL role - a VM joined to DC + SQL 2012, 2014 (2016 in progress)
* SharePoint role - a VM joined to DC + SP2013/SP2013 SP1 (2016 is in progress)

Altogether, metabox offers an end-to-end workflow to build SharePoint environments in fully automated manner. In turns, metabox can also be run under CI/CD pipelines.

## Getting started guides
* Windows 2012 stack (in progress)
* [Windows 2012-R2 stack](https://github.com/subpointsolutions/metabox/wiki/metabox-guides-win2012-r2)
* Windows 2016 stack (in progress)

## Tech overview
Metabox itself is a Ruby-based application. The following technology stack is used to get all things up and running:

* Ruby - metabox is written in Ruby 
* Rake - metabox exposes a bunch of Rake tasks
* Packer/Vagrant - metabox orchestrates Packer/Vagrant 
* Docker - metabox is developed under a Docker container 

While it may seem crazy, this technology stack allows Metabox to work on various platforms. Here is what we tested so far:
* Windows 2008
* Windows 10
* Windows 2016
* MacOS 

Furthermore, Packer/Vagrant provision is made using the following tech:
* bash scripts / ServerSpec (for metabox Jenkins2 CI)
* PowerShell, Pester
* PowerShell DSC (various configurations for DC, SQL, SharePoint DSC)
* Ruby Sinatra (to expose files via HTTP server to Vagrant VMs)

## gem builds
```
# build and install gem
gem build *.gemspec && gem install --local *.gem --no-ri --no-rdoc
```

## metabox docker build

```
# build jenkins2 container
cd /app/ci/metabox-jenkins2 && docker build --tag subpoint/metabox-jenkins2 .

# build metabox ruby dev container
cd /app/metabox
docker run --rm -it -v $(pwd):/app  --entrypoint bash subpoint/metabox-ruby

# build ruby gems
cd /app/metabox
gem build *.gemspec

gem build *.gemspec && gem install --local *.gem --no-ri --no-rdoc
```

## Jenkins2 runs:

```
vagrant up
vagrant ssh

docker run -p 8080:8080 -p 50000:50000 -v /app/ci/metabox-jenkins2:/app  subpoint/metabox-jenkins2

# then on the host, connect the agent
powershell ". ./src/ci/metabox-ci.ps1; Mb-InitSlave 8095 metabox-host-agent"
pwsh -c ". ./src/ci/metabox-ci.ps1; Mb-InitSlave 8095 metabox-host-agent"

```

## Feature requests, support and contributions
Metabox is a part of the SPMeta2 ecosystem. In case you have unexpected issues or keen to see new features just create a new GitHub issue and check documentation available:

* [Metabox issue tracker](https://github.com/SubPointSolutions/metabox/issues)
* [Metabox documentation](https://github.com/SubPointSolutions/metabox/wiki)

