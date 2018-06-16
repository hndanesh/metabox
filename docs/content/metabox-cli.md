# Metabox CLI
Metabox is a Ruby based application which exposes a bunch of Rake tasks. That makes it possible to run metabox on windows, macbook and possible linux platforms without issues. We tested it well on windows 2008, windows 2016, windows 10 and MacOS.

In order to run metabox, several environment variables should be set first. Check "metabox documents environment variables" and minimal configurations. 

## Minimal configurations
It is recommended to create a few config files, define variables there, and then source them before running metabox itself. Here is how it can be done:

macos, .config.sh
```
METABOX_SRC_PATH="$(pwd)" \
METABOX_WORKING_DIR="~/__metabox_beta_working_dir" \
METABOX_DOCUMENT_FOLDERS="$(pwd)/documents,$(pwd)/documents_download,$(pwd)/documents_canary,$(pwd)/documents_stacks" \
METABOX_LOG_LEVEL="INFO" \
$1
```

Windows, .config.bat
```
# windows
SET "METABOX_SRC_PATH=%cd%"^
 && SET "METABOX_WORKING_DIR=H:/__metabox_beta_working_dir"^
 && SET "METABOX_DOCUMENT_FOLDERS=%cd%/documents,%cd%/documents_download,%cd%/documents_stacks"^
 && SET "METABOX_LOG_LEVEL=INFO"^
 && SET "METABOX_GIT_BRANCH=120-yaml-refactoring"
```

Once these files are created, you can run metabox as this:
```
# macos
clear && source .config.sh "rake"
# windows
cls && .config.win.bat && rake 
```

Multiple commands can be ru as this:
```
# macos
clear && source .config.sh "rake resource:generate resource:list"
# windows
cls && .config.win.bat && rake resource:generate && rake resource:list 
```

## Rake tasks 
Metabox exposes Rake tasks. There are a few sets of the rake tasks to address the following actions:
* configure metabox and 3rd part tools
* download files
* work with packer
* work with vagrant

Metabox tries to "proxy" most of packer/vagrant commands by following similar name convention within Rake tasks:
* rake vagrant:up -> vagrant up
* rake vagrant:destroy -> vagrant destroy
* rake packer:build -> packer build

Most of the Rake tasks consume a "resource name" from the metabox document. You always work with "metabox document resource", not with the VM or packer build directly. Metabox does a heavy lifting, processes documents, generates packer config and vagrant VM, and then allows access to it via "resource name". Here is a mostly used format:

* rake packer:build[resource_name] 
* rake vagrant:up[stack_name::resource_name] 

Additional parameters are passed to packer/vagrant via Rake task such as:
* rake packer:build[resource_name,-f]  -> packer build -force
* rake vagrant:up[stack_name::resource_name,--provision]  -> vagrant up --provision
 
As metabox provides a concept of "stacks", a set of Vagrant VMs, it comes handy to batch operations within VM stack: provision all VMs, halt or destroy all VMs. Rake tasks has a special resource called "_all", which means that a task will be run against all resource with "stack" or "fileset":

* rake vagrant:halt[stack_name::_all]
* rake vagrant:destroy[stack_name::_all]

Below are all tasks which are available right now:

### Getting list of available tasks
This is a built-in Rake feature which lists all tasks and descriptions: 
```
# get list of rake tasks and their descriptions
rake --tasks
rake -T
```

### rake metabox
These tasks provide access to metabox self-configuration; configuring vagrant, packer and 3rd part tools.

```
# download and install 3rd party tools
rake metabox:bootstrap

# configure vagrant, install plugins
rake metabox:vagrant_config
```

### rake resource
These tasks provide capabilities to work with metabox documents; parsing documents to generate Packer/Vagrant configurations, listing resulting resources.

```
# generate Packer/Vagrant configs off the metabox documents
rake resource:generate

# get list of all resources
rake resource:list
```

### rake fileset
These tasks provide capabilities to download files defined in metabox documents.

```
# download particular file 
rake fileset:download[fileset_resource_name::resource_name]
# download all files in a resource
rake fileset:download[fileset_resource_name::_all]
```

### rake packer
These tasks provide tasks to work with packer.

```
# build packer resource by its name
rake packer:build[resource_name]
rake packer:build[resource_name,--force]

```

### rake vagrant
These tasks provide tasks to work with vagrant.

```
# add vagrant box by its name
rake vagrant:add[resource_name]
rake vagrant:add[resource_name,--force]

# run particular or all virtual machine by resource name
rake vagrant:up[stack_name::resource_name]
rake vagrant:up[stack_name::resource_name,--provision]
rake vagrant:up[stack_name::_all]
rake vagrant:up[stack_name::_all,--provision]

# destroy particular virtual machine by resource name
rake vagrant:destroy[stack_name::resource_name]
rake vagrant:destroy[stack_name::resource_name,--provision]
rake vagrant:destroy[stack_name::_all]

# halt particular virtual machine by resource name
rake vagrant:halt[stack_name::resource_name]
rake vagrant:halt[stack_name::resource_name]
rake vagrant:halt[stack_name::_all]

# reload particular virtual machine by resource name
rake vagrant:reload[stack_name::resource_name]
rake vagrant:reload[stack_name::resource_name]
rake vagrant:reload[stack_name::_all]

# vagrant status
rake vagrant:status

# vagrant validate
rake vagrant:validate

# vagrant box list
rake vagrant:box_list

# vagrant global status
rake vagrant:global_status

```

### hot deploy, optional provision with "rake vagrant"
While Vagrant offers "--provision" mode to enforce and re-apply script provision to a VM, sometimes we are interested in running only a particular set of provision scripts ignoring most of of the current scripts. 

Examples of this are:
* skipping DC controller provision
* skipping host reboots and reloads
* skipping heavy provision operations which were already applied
* skipping file transfers
* skipping domain joins and reboots

This comes handy in testing, in hot-deploy scenarios such as re-applying a particular configuration or script to a VMs, testing a particular feature deployment. Here is how it works:

* instead of commenting out YAML sections, we leave document untouched and use "Tags" section in YAML
* we run "vagrant:up[soe-win2012::sql,--provision,provision_tags=soe+sql]"

3rd parameter is a set of "provision tags" with "+" separator. These are tags which correspond to at least one value in "Tags" array in YAML document:

Example of SQL server provision, check "Tags" values at every section:
```yaml
        sql:
          VagrantTemplate:
            - Type: "vagrant::config::vm"
              Properties:
                # building off app box, bin files will be transfered on the fly
                box: "Fn::GetParameter box_win12_app"

            - Type: "vagrant::config::vm::provider::virtualbox"
              Properties:
                cpus: 4
                memory: 4096
                machinefolder: "Fn::GetParameter custom_machine_folder"

            - Type: "metabox::vagrant::host"
              Properties:
                hostname: "Fn::GetHostName"
          
            - Type: "metabox::vagrant::win12soe"
              Tags: [ "soe" ]
              Properties:
                execute_tests: true
         
            - Type: "metabox::vagrant::dcjoin"
              Tags: [ "dc-join" ]
              Properties:
                execute_tests: true

                # dc specific parameters
                dc_domain_name: "Fn::GetParameter dc_domain_name"
                dc_join_user_name: "Fn::GetParameter dc_domain_admin_name"
                dc_join_user_password: "Fn::GetParameter dc_domain_admin_password"

            # transfer files
            - Type: "metabox::vagrant::shell"
              Tags: [ "bin" ]
              Properties:
                path: "./scripts/packer/_metabox_dist_helper.ps1"
                env: 
                  - "METABOX_RESOURCE_NAME=sql2012sp2"
            
            # provision SQL
            - Type: "metabox::vagrant::sql12"
              Tags: [ "sql" ]
              Properties:
                execute_tests: true

                # SQL specific params
                sql_bin_path: "Fn::GetParameter sql_bin_path"
                sql_instance_name: "Fn::GetParameter sql_instance_name"
                sql_instance_features: "Fn::GetParameter sql_instance_features"
                sql_sys_admin_accounts:
                  - "vagrant"
                  - "soe-win2012\\vagrant"
``` 

## Build workflows

Metabox provides a set of Rake tasks to download files, parse metabox documents to generate packer configs and vagrant VMs, and then run packer builds and vagrant VMs in batch. While every task does a single operation, we are mostly interested in end-to-end workflows to build images and VMs.

Below are some workflows which metabox can perform. Prior this, please check out how the metabox cli works and how minimal configuration is done.

Most of the times, you would be required to run 2-3 tasks in a row:
* resource:generate -> to generate Packer/Vagrant configs off the metabox documents
* resource:list -> to output resource available

Then, depending on a task, three scenarios are available:
* fileset:download -> to download one or all files
* packer:build + vagrant:add -> to build packer and then add image as a Vagrant box
* vagrant:up, vagrant:halt, vagrant:destroy -> to build one or many VMs

All commands above should be run from `/src` directory

## Using MacOS host
## Using Windows host
### Installing Windows 2012 R2 and SharePoint 2013 with SP1
#### Downloading files
Requirements:
1. Previous section is complete: Installation
2. 20GB free disk space on working directory drive
3. 1-4 hours (depending on the Internet connection speed)

```
# generate resource, list them, and then download all resources in "7zip" fileset
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[7zip::_all]

# download SharePoint Designer
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[spd2013::_all]

# download SQL Server
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[sql::sql2012sp2]
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[sql::sql2014sp1]

```
Unfortunately, the only feasible way of downloading SharePoint 2013 with SP1 is using MSDN or volume license. You should therefore download it manually:
1. Download ISO file from MSDN or Volume License into <metabox_beta_working_dir>/metabox_downloads/sp2013sp1
2. Run `cd <metabox_beta_working_dir>/metabox_downloads/sp2013sp1 && 7z -v500m a zip/dist.zip <iso_file_name> && cd <metabox_repo>\src`

#### Building boxes (VM images)
Requirements:
1. Previous section is complete: downloading files
2. 50GB free disk space on working directory drive
3. 20GB free disk space on VM drive
4. 4GB RAM available
5. 1-4 hours (depending on the Internet connection speed, CPU, Memory and disk performance)

For building boxes run following commands:
```
cls && .config.win.bat && rake resource:generate && rake packer:build[win2012-r2-mb-soe,-force] && rake vagrant:add[win2012-r2-mb-soe,--force]
cls && .config.win.bat && rake resource:generate && rake packer:build[win2012-r2-mb-app,-force] && rake vagrant:add[win2012-r2-mb-app,--force]
cls && .config.win.bat && rake resource:generate && rake packer:build[win2012-r2-mb-bin-sp13,-force] && rake vagrant:add[win2012-r2-mb-bin-sp13,--force]

```

#### Provisioning the environment
Requirements:
1. Previous section is complete: building boxes
2. 30GB free disk space on VM drive
3. 14GB RAM available
4. 1-4 hours (depending on the Internet connection speed, CPU, Memory and disk performance)
5. Run `rake metabox:configure_vagrant`

Run following commands:
```
cls && .config.win.bat && rake resource:generate && rake vagrant:up[soe-win2012-r2::dc]
cls && .config.win.bat && rake resource:generate && rake vagrant:up[soe-win2012-r2::client]
cls && .config.win.bat && rake resource:generate && rake vagrant:up[soe-win2012-r2::sql12]
cls && .config.win.bat && rake resource:generate && rake vagrant:up[soe-win2012-r2::sp13_first]

```
For shutting down all machines, run following commands:
```
cls && .config.win.bat && rake resource:generate && rake vagrant:halt[soe-win2012-r2::_all]

```
For destroying all machines, run following commands:
```
cls && .config.win.bat && rake resource:generate && rake vagrant:destroy[soe-win2012-r2::_all,--force]

```

## Downloading files
```
# generate resource, list them, and then download all resources in "7zip" fileset
clear && . .config.sh "rake resource:generate resource:list fileset:download[7zip::_all]"
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[7zip::_all]

# download SharePoint Designer
clear && . .config.sh "rake resource:generate resource:list fileset:download[spd2013::_all]"
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[spd2013::_all]

# SP2013 RTM
clear && . .config.sh "rake resource:generate resource:list fileset:download[spd2013_prerequisites::_all]"
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[spd2013_prerequisites::_all]

# SP2013 RTM
clear && . .config.sh "rake resource:generate resource:list fileset:download[sp2013::_all]"
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[sp2013::_all]

# SP2013 SP1
#first, download ISO file from MSDN or Volume License into <metabox_beta_working_dir>/metabox_downloads/sp2013sp1
cd <metabox_beta_working_dir>/metabox_downloads/sp2013sp1 && 7z -v500m a zip/dist.zip <iso_file_name> && cd <metabox_repo>\src

# SP2016
clear && . .config.sh "rake resource:generate resource:list fileset:download[sp2016::_all]"
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[sp2016::_all]


# SQL
clear && . .config.sh "rake resource:generate resource:list fileset:download[sql::_all]"
cls && .config.win.bat && rake resource:generate && rake resource:list && rake fileset:download[sql::_all]

```

### Building Windows 2012 stack (soe, app, sql and SharePoint images)
```
# windows 2012
clear && source .config.sh "rake resource:generate packer:build[win2012-mb-app,--force] vagrant:add[win2012-mb-app,--force]"

cls && .config.win2008.bat && rake resource:generate && rake packer:build[win2012-mb-soe,-force] && rake vagrant:add[win2012-mb-soe,--force]

# windows 2012 -> app image
clear && source .config.sh "rake resource:generate packer:build[win2012-mb-app,--force] vagrant:add[win2012-mb-app,--force]"

cls && .config.win2008.bat && rake resource:generate && rake packer:build[win2012-mb-app,-force] && rake vagrant:add[win2012-mb-app,--force]

# app -> sharepoint 2013
clear && source .config.sh "rake resource:generate packer:build[win2012-mb-app,-force] vagrant:add[win2012-mb-app,--force]"

cls && .config.win2008.bat && rake resource:generate && rake packer:build[win2012-mb-bin-sp13,-force] && rake vagrant:add[win2012-mb-bin-sp13,--force]

# app -> sql 2012
clear && source .config.sh "rake resource:generate packer:build[win2012-mb-bin-sql12,-force] vagrant:add[win2012-mb-bin-sql12,--force]"

cls && .config.win2008.bat && rake resource:generate && rake packer:build[win2012-mb-bin-sql12,-force] && rake vagrant:add[win2012-mb-bin-sql12,--force]

```


### Building 2016 Images on Windows
```
cls && .config.win.bat && rake resource:generate && rake packer:build[win2016-mb-soe,-force] && rake vagrant:add[win2016-mb-soe,--force]
cls && .config.win.bat && rake resource:generate && rake packer:build[win2016-mb-app,-force] && rake vagrant:add[win2016-mb-app,--force]
cls && .config.win.bat && rake resource:generate && rake packer:build[win2016-mb-bin-sp16,-force] && rake vagrant:add[win2016-mb-bin-sp16,--force]

```

### Building Vagrant stack of DC, SQL, SharePoint 2013
```
# build all VMs
clear && source .config.sh "rake resource:generate vagrant:up[soe-win2012::_all,--provision]"
cls && .config.win2008.bat && rake resource:generate && vagrant:up[soe-win2012::_all,--provision]

# build a particular VM - DC only
clear && source .config.sh "rake resource:generate vagrant:up[soe-win2012::dc,--provision]"
cls && .config.win2008.bat && rake resource:generate && vagrant:up[soe-win2012::dc,--provision]

# same with vagrant:destroy, vagrant:halt
``

