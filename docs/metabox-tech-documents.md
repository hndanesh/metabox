## Metabox documents

This document describes a high level ideas behind "metabox documents". While most of the documentation for metabox documents can be found in "Metabox documents overview" section, this pages focuses on some technical implementations happening behind the scenes.

### The problem
Some time ago, we were looking into a consistent workflow to create SharePoint environments with easiness. A typical SharePoint environment consists of at least 3 servers and include the following:
* domain controller
* SQL server
* SharePoint server

Depending on the role and scenarios, we might also need to install additional software, such as Visual Studio, or may need additional servers such as secondary domain controllers, additional SQL servers, additional SharePoint servers for web front-end, search or other roles.

The very complexity comes with several areas:
* easy VM creation
* easy network setup (ensure server can talk to each other and internet)
* patches installation 
* software installation and configuration 
* testing, testability and ensuring that infrastructure and software installed correctly
* blue/green deployments

All these challenges scale with amount of virtual machines we need, various platforms versions (Windows 2012/2016), various software versions (SharePoint 2013, 2016 or SQL 2012, 2014, 2016). 

These problems aren't new. As a single problem, here is how every area can be addressed:

* vagrant: easy VM creation
* vagrant: easy network setup (ensure server can talk to each other and internet)
* packer: patches installation 
* packer, vagrant, configuration management: software installation and configuration 
* packer, vagrant, Pester/ServerSpec: testing, testability and ensuring that infrastructure and software installed correctly
* defined approach for CI/CD: blue/green deployments

However, while a single tool can address a single problem, by default these tools don't work well with each other. It means that additional setup is required to glue tools together in a toolchain such as:
* produce patched image with packer
* produce other images based off newly created patched image with packer
* manage packer images
* add these images to vagrant
* spin up virtual machines off newly created images, manage network
* configure provision; create DCs, install SQL, SharePoint and so on

Ideally, we would like to see a highly-automated way to perform these activities which can be placed under CI/CD within blue/green deployment model.

Simply saying: all these problems can be solved with tools, but end-to-end toolchain does not come by default; it has to be built from scratch to glue all tools together in a smooth, unattended workflow. 

### Why did we come up with metabox documents
A very minimalistic workflow to get SharePoint server provisioned looks like this:
* create packer image
* import box to vagrant
* spin up 3 virtual machines; DC, SQL and SharePoint

The tech stack for this would looks like:
* virtual box, packer and vagrant to handle low-level infrastructure details
* PowerShell/DSC to handle configuration management tasks
* PowerShell/Pester to test applied configurations

Again, every task can be performed individually with easiness but end0-to-end workflow requires passing data from one tool to another; from packer to vagrant, and then within vagrant - between virtual machines (such as SQL server host name, domain name and so on). Apart that, every tool has got its own way to work with; configuration is stored in JSON for packer, and Vagrant requires Ruby based DSL as an input.

That's where metabox documents play well. They glue things together abstracting low-level details of every tool. Here is several main parts which are addressed with metabox documents:
* defining "resources"
* defining "resources" properties
* defining relationships between "resources"
* defining which data needs to be passed between "resources"
* defining "pre/post" script hooks for veery resource

Resource here is either a file to be downloaded, a packer build, a vagrant virtual machine. Metabox documents makes it easier to express what needs to be done, which data and how needs to be passed between packer build and vagrant virtual machine. 
 
### YAML based configurations to rule them all
Metabox documents are YAML based configuration which defines various "resources":
* files to be downloaded
* packer builds
* vagrant virtual machines

We understand that YAML is pretty "static" then it comes to parametrisation and reusing variables, so we come up with various "function" and "tokens" which brings more dynamic nature to YAML documents. The following things can be done in metabox YAM documents:

* passing environment variables into YAML values
* referring to other YAML values 

In turn, such simple parametrisation concept enables building packer/vagrant resources at scale, with prefixes/postfixes. This is important because at some sense, it enables "blue/green" deployment model at packer/vagrant level: every resource, such as packer build or vagrant VM can be parametrised with current git branch value so that separate artefacts would be produced as per git branch. That allows us to test infrastructure faster, work on "non-master" branches without changing "master" deployed infrastructure. 

### Documents structure and processing
As mentioned, metabox documents are YAML files which define various "resources"; files to be downloaded, packer builds and vagrant VMs.

Every document has got a minimal valid structure, and then one or many resources. Here is an example on how it works:

```yaml
Metabox:
  Description: My document
  Parameters:
    custom_machine_folder: "c:/_metabox_vms/"
    domain_name: "metabox.local"

  Resources:
    # files to download
    win2012-distributives:
        # some properties here

    # packer image build
    win2012-packer-image:
        # some properties here
    
    win2012-r2-packer-image:
        # some properties here

    # vagrant stack of VMs
    win2012-vagrant-vms:
        Resources:
            win2012-vagrant-dc:
            # some properties here
            
            win2012-vagrant-sql:
            # some properties here
         
```

That way, metabox makes it easy to describe infrastructure, provision and additional file downloads in a single place. We can re-use variables, pass environment variables, refer to variables between various resources.

Metabox then processes these YAML documents producing packer JSOn files and Vagrant VM configurations. 