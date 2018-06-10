## Metabox technocal design

This section describes various concepts and implementation within metabox; documents, resources and other internal things.

Please refer to section on the right to get more insight on a particular subject. 

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


## Metabox file resources

Before reading this, make sure you are familiar with metabox document concepts. This section focuses on how meabox file resources works; from downloading, packaging, to passing to Packer builds and Vagrant VMs.

### Problem
While provisioning complex environments such as SQL or SharePoint, additional files have to be downloaded; ISO images and installation media. Not only we might have many files to download and managed, but they are also quite huge, from 500Mb to 3-4Gb, and hence the following challenges arise straight away:
* how to define all these files
* how to download them
* where and how to store them
* how to pass them to Packer builds
* how to pass them to Vagrant VMs

Downloading and storing files is not something new but passing them to Packer builds and Vagrant VMs might be quote a challenge: different hyper-visor might or might not provide a good file transfer capabilities, Packer and Vagrant handle this operation differently, besides Vagrant might perform fast on windows 2012 but slow on windows 2016.

Downloading is another challenge; we need to ensure files are downloaded correctly.

Finally, storing these files could be a challenge itself; total amount of data might be around 50-75Gb which could impact your storage. It should be easier to plug additional storage and re-point metabox to this storage.

As you can see, file handling is a problem itself. Hence, metabox solves it providing a built-in, consistent experience over the following areas:

* defining files in metabox documents along with packer/vagrant builds and VMs
* downloading files, using SHA1 hash to check file integrity and avoid re-downloading
* built-in pre/post download script hook (metabox executes your scripts before/after file downloads)
* built-in capabilities to transfer huge files into Packer builds (via http_directory virtual box feature)
* built-in capabilities to transfer huge files into Vagrant VMs (via sinatra based local http web server)
* built-in scripts to pack/unpack huge files into smaller zip files, ISO unpacking 

All this gives you a fluent experience over file downloading and transferring them into Packer/Vagrant so that you can focus on provisioning instead.

### Defining what to download
Metabox document is used to define what to download and where to store it. Here is a very simple configuration which gets 7zip files downloaded:

```yaml
Metabox:
  Description: Downloads additional software
    
  Resources:
    7zip:
      Type: "metabox::http::file_set"
      Resources:
        7zip-17.01-x86:
          Type: "metabox::http::file"
          Properties:
            SourceUrl: "http://www.7-zip.org/a/7z1701.exe"
            DestinationPath: "${ENV:METABOX_DOWNLOADS_PATH}/7zip/7z1701-x86.exe"
            Checksum:
              Enabled: true
              Type: "sha1"
              Value: "2c94bd39e7b3456873494c1520c01ae559bc21d7" 
            Hooks:
              Pre: 
                Inline: 
                  - "echo 'pre-download'" 
              Post: 
                Inline: 
                  - "echo 'post-download'"       
        
        7zip-17.01-x64:
          Type: "metabox::http::file"
          Properties:
            SourceUrl: "http://www.7-zip.org/a/7z1701-x64.exe"
            DestinationPath: "${ENV:METABOX_DOWNLOADS_PATH}/7zip/7z1701-x64.exe"
            Checksum:
              Enabled: true
              Type: "sha1"
              Value: "9f3d47dfdce19d4709348aaef125e01db5b1fd99" 
            Hooks:
              Pre: 
                Inline: 
                  - "echo 'pre-download'" 
              Post: 
                Inline: 
                  - "echo 'post-download'"       
        

```

Metabox uses "metabox::http::file_set" resource - a set of individual file. Such resource then has got nested resources of type "metabox::http::file". It makes it easier to manage and download either one file or all files in a batch.

Internally, metabox spins 5 threads to download all files in the fileset. If checksum flag is "true", then metabox checks if local file has got the right checksum avoiding another trip to re-download file.

"METABOX_DOWNLOADS_PATH" environment variable is used to store files. By default, metabox used "METABOX_WORKING_DIR\metabox_downloads" path but you can change it as you wish. That makes it possible to use external drives or other drives to store and manage installation media.

Finally, before-after download a custom script is called via "Pre/Post" hooks. Current directory is set to the downloaded file directory so you can refer to file by its name. Later, we use these hooks to package large files with 7zip into smaller, 500Mb zip archives as this:

```yaml
Metabox:
  Description: Downloads SharePoint Designer
    
  Resources:
    spd2013:
      Type: "metabox::http::file_set"
      Resources:  
        spd_x32:
          Type: "metabox::http::file"
          Properties:
            SourceUrl: "https://download.microsoft.com/download/3/E/3/3E383BC4-C6EC-4DEA-A86A-C0E99F0F3BD9/sharepointdesigner_32bit.exe"
            DestinationPath: "${ENV:METABOX_DOWNLOADS_PATH}/spd2013_x32/sharepointdesigner_32bit.exe"
            Checksum:
              Enabled: true
              Type: "sha1"
              Value: "7be30cadc49d66f116ab4aa303bbfed937846825" 
            Hooks:
              Pre: 
                Inline: 
                  - "echo 'pre-download'" 
              Post: 
                Inline: 
                  - "7z -v500m a zip/dist.zip sharepointdesigner_32bit.exe" 
        spd_x64:
          Type: "metabox::http::file"
          Properties:
            SourceUrl: "https://download.microsoft.com/download/3/E/3/3E383BC4-C6EC-4DEA-A86A-C0E99F0F3BD9/sharepointdesigner_64bit.exe"
            DestinationPath: "${ENV:METABOX_DOWNLOADS_PATH}/spd2013_x64/sharepointdesigner_64bit.exe"
            Checksum:
              Enabled: true
              Type: "sha1"
              Value: "60041617c421962c28e71f712e299e29f51651fb" 
            Hooks:
              Pre: 
                Inline: 
                  - "echo 'pre-download'" 
              Post: 
                Inline: 
                  - "7z -v500m a zip/dist.zip sharepointdesigner_64bit.exe"
```

### Huge files handling
Metabox provides "Pre/Post" hooks to execute your scripts. By default, we package all files with "7zip" into smaller, 500Mb archives with the following cmd:

```
"7z -v500m a zip/dist.zip sharepointdesigner_64bit.exe"
```
 
Every file resource then would have a "zip" folder, which then later exposed to Packer and Vagrant:
* Packer -> virtual box, "http_directory" is used
* Vagrant -> local web server based on "sinatra" is used

Under packer, you can access these files under "PACKER_HTTP_ADDR" environment variable. Sometime this variables is null (under windows 2008 host), so script simple scans all ports between 8000-9000 to find active web-server provided by Virtual Box.

Under vagrant, metabox spins up a local web server with "sinatra" and then passes "METABOX_HTTP_ADDR" variable to builds scripts.

Finally, "_metabox_dist_helper.ps1" checks all these environment variables and makes file downloads to the target host; either under Packer or Vagrant. This is very cool, a consistent approach to transfer files plus it works well on huge, really large files. It makes it also easier to migrate this project to AWS/Azure environments; simple "METABOX_HTTP_ADDR" variable would enable easy web transfer for these builds.

As metabox exposes "ENV:METABOX_DOWNLOADS_PATH" folder over HTTP, passing either "PACKER_HTTP_ADDR" or "METABOX_HTTP_ADDR" to host VMs, we can refer to files by their "resource name" and "zip" folders. "_metabox_dist_helper.ps1" uses "METABOX_RESOURCE_NAME" variables to fetch all "zip" files, download them, unpack, detect ISO and unpack it, or detect non-iso and move it to "METABOX_RESOURCE_DIR". 

What you get at the end, is "METABOX_RESOURCE_DIR" on target VM folder which looks like a replica of "METABOX_DOWNLOADS_PATH" for a giving resource.

## Metabox packer resources

Before reading this, make sure you are familiar with metabox document concepts. This section focuses on how metabox packer resources work; defining packer builds and working with parametrisation.

### Problem
Packer provides JSON based configuration to define image builds. This makes it hard to glue input/output of packer  to other tools, re-use packer template blocks, add comments and manage parameters. As an outcome, we end up with inconsistent configurations, lengthy JSOn templates without any comments on how/why thins done, no ability to comment/uncomment sections and parametrisation via variables or variable file is a bit hard to deal with. Finally, packer configurations can't really be reused unless we generate them, on the fly. That makes configs lengthy, with copy-paste being one of the favourite methods of authoring. 

### Metabox approach to Packer builds files
Metabox move Packer configuration into YAML based metabox document; welcome comments, parametrisation and custom handlers to produce required data. Once done, metabox generates a JSON template and then runs Packer off this template.

Here is how a simple build can looks like:
```yaml
Metabox:
  Description: Builds CentOS7 with pre-installed Java8
  Parameters:
    custom_machine_folder: "${ENV:METABOX_WORKING_DIR}/vagrant_vms/metabox_canary_centos7"

  Resources:
    centos7-mb-java8:
      Type: "metabox::packer::build"
      Parameters:
        box_name: "geerlingguy/centos7"
      Properties:
        PackerFileName: "centos7-mb-java8.json"
        VagrantBoxName: "centos7-mb-java8-${ENV:METABOX_GIT_BRANCH}"
        PackerTemplate:
          variables:
            metabox_git_branch: "Fn::Env METABOX_GIT_BRANCH"
            metabox_working_dir: "Fn::Env METABOX_WORKING_DIR"
            centos7-mb-java8.yum: "git,vim,wget"
          builders:
            - Type: "packer::builders::vagrant_centos7"
              Properties:
                box_name: "geerlingguy/centos7"
                builder:
                  output_directory: "{{ user `metabox_working_dir` }}/packer_output/centos7-mb-java8-{{ user `metabox_git_branch` }}"
          provisioners:
            - Type: "packer::provisioners::shell_centos7"
              Properties:
                scripts:
                  - "./scripts/packer/shared/mb_printenv.sh"
                  - "./scripts/packer/shared/mb_yum_install.sh"
                  - "./scripts/packer/shared/mb_java8_install.sh"
                environment_vars: 
                  - "METABOX_YUM_PACKAGES={{ user `centos7-mb-java8.yum`  }}"
          post-processors: 
            - Type:  "packer::post-processors::vagrant"
              Properties:
                "output": "{{ user `metabox_working_dir` }}/packer_boxes/centos7-mb-java8-{{ user `metabox_git_branch` }}-{{.Provider}}.box"
        
```

### metabox::packer::build resource

The main resource for Packer builds is "metabox::packer::build". A simplest configiration looks as following:
```yaml
Metabox:
  Description: Builds CentOS7 with pre-installed Java8
  Parameters:
    custom_machine_folder: "${ENV:METABOX_WORKING_DIR}/vagrant_vms/metabox_canary_centos7"

  Resources:
    centos7-mb-java8:
      Type: "metabox::packer::build"
      Parameters:
        box_name: "geerlingguy/centos7"
      Properties:
        PackerFileName: "centos7-mb-java8.json"
        VagrantBoxName: "centos7-mb-java8-${ENV:METABOX_GIT_BRANCH}"
        PackerTemplate:
            # a valid hash which will be translated into Packer JSON template
```

Three properties are:

| Function        |  Comments  |
| -------------   | -----:|
| PackerFileName | File name for generate packer template |
| VagrantBoxName|  Vagrant box name, it will be used to add this box to Vagrant |
| PackerTemplate | A hash which gets translated into Packer JSON template |


Simply saying, you can put any Packer template in YAML format under "PackerTemplate" file and it will work without issues.

Having said that, we abstracted some YAML sections into "handlers" which heavy-lift most of the properties and allow us to come up with much more cleaner templates:

* packer::builders::vagrant_centos7
* packer::builders::vagrant_win12_sysprep
* packer::builders::vagrant_win12_shutdown
* packer::builders::vagrant_win16_sysprep

These handlers return a valid YAML section pre-filled with default values. You can, however, override these values putting you own values into YAML document.

For instance, here is what "packer::builders::vagrant_centos7" returns:
```ruby
properties = {
                "type" => "vagrant",

                "box_name" => "geerlingguy/centos7",
                "box_provider" => "virtualbox",
                "box_file" => ".ovf",

                'builder' => {
                    "output_directory" => "output-centos7-mb-canary-{{ user `metabox_git_branch` }}",
                    "type" =>  "virtualbox-ovf",
                    "headless" =>  'true',
                    "boot_wait" =>  "30s",
                    "ssh_username" =>  "vagrant",
                    "ssh_password" =>  "vagrant",
                    "ssh_wait_timeout" =>  "8h",
                    "shutdown_command" =>  "sudo -S sh -c '/usr/sbin/shutdown -h'",
                    "shutdown_timeout" => "15m"
                }
            }
```

Later on, in metabox document, we use it as this, focusing only on important properties. All other properties are delivered by default via "packer::builders::vagrant_centos7" and are common across all Packer configurations. Hence, we re-use these properties hiding them into Ruby-based handler, and metabox then processes YAML document calling Ruby handler for every section.

```yaml
builders:
            - Type: "packer::builders::vagrant_centos7"
              Properties:
                box_name: "geerlingguy/centos7"
                builder:
                  output_directory: "{{ user `metabox_working_dir` }}/packer_output/centos7-mb-java8-{{ user `metabox_git_branch` }}"

```

Same thing happens to other handlers, search for these string in the Ruby code base to get understanding what they return:
* packer::builders::vagrant_centos7
* packer::builders::vagrant_win12_sysprep
* packer::builders::vagrant_win12_shutdown
* packer::builders::vagrant_win16_sysprep



## Metabox vagrant resources

Before reading this, make sure you are familiar with metabox document concepts. This section focuses on how metabox vagrant resources work; defining vagrant VMs working with parametrisation.

### Problem
Vagrant provides a Ruby DSL to configure VMs. While it is one of the best ways to express custom VM build, it also different to what Packer offers, plus does not have a build-in way to bridge data between Packer/Vagrant. 

A large heavy-lifting for every VMs requires attention as well; from shared folders, to networking, hostnames and so on. Too much to configure, and this configuration might be shared betwen all VMs. Passing params from one VM to another is another challenge - for instance, as hostname of SQL server to SharePoint server.

Machine folder is a huge challenge; by default Vagrant stored VMs in system drive. Splitting Vms across multiple drives, such as per 6 additional SSD drives is hardly possible by default unless a custom code and DSL is written.

Finally, multi-Vms environment management does not come with Vagrant by default; from network isolation to batch operations against every VMs in the "environment".

### Metabox approach to Packer builds files
Metabox moves Vagrant VM configuration into YAML based metabox document; welcome comments, parametrisation and custom handlers to configure VM. Once done, metabox runs only one "Vagrantfile" referring to metabox API and using metabox document to read/configure Vagrant VMs on the fly. All information is stored in metabox document; VMs and their configurations. 

Metabox handles:
* VMs configurations
* networking and isolation between enironments
* file transfers
* batch operations in multi-VM environment
* hostnames

To make it possible, metabox introduces two types of resources:
* "vagrant::stack" -> a set of VMs isolated in a dedicated private subnet
* "vagrant::stack::vm" -> represent a VMs within "vagrant::stack"

Finally, all VMs configurations are abstracted into special handlers to configure Vagrant-specific properties:
* vagrant::config::vm
* vagrant::config::vm::provider::virtualbox
* vagrant::config::vm::network
* vagrant::vm:provision

And custom, metabox-provided handlers to heavy-lift custom provision for DC, SQL, SharePoint and so on:
* metabox::vagrant::host
* metabox::vagrant::win12so
* metabox::vagrant::shell
* metabox::vagrant::dc12
* metabox::vagrant::sql12
* metabox::vagrant::sp13-wfe


A simple stack consisting of 3 VMs loosk as following:
```yaml
Metabox:
  Description: Builds Vagrant VMs to trigger Vagrant box downloads
  Parameters:
    box_win2012:    "opentable/win-2012-standard-amd64-nocm"
    box_win2012_r2: "opentable/win-2012r2-standard-amd64-nocm"

    box_centos7: "geerlingguy/centos7"

    custom_machine_folder: "${ENV:METABOX_WORKING_DIR}/vagrant_vms/metabox_boxes"
  Resources:
    
    metabox-boxes:
      Type: "vagrant::stack"
      
      Resources:
        win2012:
          VagrantTemplate:
            - Type: "vagrant::config::vm"
              Properties:
                box: "Fn::GetParameter box_win2012"

            - Type: "vagrant::config::vm::provider::virtualbox"
              Properties:
                cpus: 2
                memory: 512
                machinefolder: "Fn::GetParameter custom_machine_folder"

        win2012-r2:
          VagrantTemplate:
            - Type: "vagrant::config::vm"
              Properties:
                box: "Fn::GetParameter box_win2012_r2"

            - Type: "vagrant::config::vm::provider::virtualbox"
              Properties:
                cpus: 2
                memory: 512
                machinefolder: "Fn::GetParameter custom_machine_folder"

        centos7:
          VagrantTemplate:
            - Type: "vagrant::config::vm"
              Properties:
                box: "Fn::GetParameter box_centos7"

            - Type: "vagrant::config::vm::provider::virtualbox"
              Properties:
                cpus: 2
                memory: 512
                machinefolder: "Fn::GetParameter custom_machine_folder"
```