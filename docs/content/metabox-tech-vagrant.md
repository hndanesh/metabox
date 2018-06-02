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