## Rake tasks and how they work
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
