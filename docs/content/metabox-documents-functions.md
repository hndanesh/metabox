## Document Functions
Function allow dynamic value resolution. AWS CloudFormation Intrinsic Function Reference was an inspiration to the functions below:
> https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html

| Function        | What it does           | Comments  |
| -------------   |:-------------:| -----:|
| Fn::GetResourceProperty|Resolve resource property | |
| Fn::GetResourceParameter|Resolve current resource parameter |  |
| Fn::GetParameter|Resolve parameter, resursively up |  |
| Fn::Env|Resolve environment variable by name |  |
| Fn::GetHostName|Resolve current VM host name |  |
| Fn::GetResourceHostName|Resolve other resource VM host name |  |

### Fn::GetParameter
This function looks up a value from `Parameters` section in the document tree. We look for the first "Parameters" section up in the tree. Throwing exception if value is not found.

* Usage: `"Fn::GetParameter parameter_name"`

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
                # resolve 'box_win2012' values from upper 'Parameters' section
                # we look for the first 'Parameters' section in the document tree
                box: "Fn::GetParameter box_win2012"
```

### Fn::Env
This function looks up environment variable. Throwing exception if value is not found. There are two ways to use this function - either via "function" or "token".

* Usage: `"Fn::GetParameter environment_value_name"`
* Usage: `"${ENV:ENVIRONMENT_VALUE_NAME}"`

Tokens allow re-definition of the whole YAML section. It comes handy to de-define the whole section per git branch, for instance, and this format is heavily used to produce Packer images per metabox git branch.

```yaml
Metabox:
  Description: Builds a windows 2016 SOE image
  Parameters:
    custom_machine_folder: "${ENV:METABOX_WORKING_DIR}/vagrant_vms/metabox_canary_win2016"

  Resources:
    win2016-mb-app:
      Type: "metabox::packer::build"
      Parameters:
        box_name: "win2016-mb-soe-${ENV:METABOX_GIT_BRANCH}"
      Properties:
        PackerFileName: "win2016-mb-app.json"
        VagrantBoxName: "win2016-mb-app-${ENV:METABOX_GIT_BRANCH}"
        PackerTemplate:
          variables:
            metabox_git_branch: "Fn::Env METABOX_GIT_BRANCH"
            metabox_working_dir: "Fn::Env METABOX_WORKING_DIR"
            http_directory: "Fn::Env METABOX_DOWNLOADS_PATH"
```

### Fn::GetHostName
This function returns a unique host name for a Vagrant virtual machine. It is usually used with `metabox::vagrant::host` provisioner to set a host name for a newly created VM.

Metabox generates a unique host name in a format "mb-unique_string", assigns it to a newly created virtual machine and then keeps track of this host name and IP within a stack of virtual machine. That means that you don't have to worry about the hostname ever, rather use metabox YAML functions to get the right value of the host name.

This function works within the current resource. If you need to lookup a host name of the other virtual machine, use `Fn::GetResourceHostName resource_name` function instead. This comes handy to resolve SQL host name, for instance.

* Usage: "Fn::GetHostName"



```yaml
Metabox:
  Description: Builds Vagrant VMs to trigger Vagrant box downloads
  Parameters:
    box_win12_soe:    "win2012-mb-app-${ENV:METABOX_GIT_BRANCH}"
    box_win12_app:    "win2012-mb-app-${ENV:METABOX_GIT_BRANCH}"

    box_win12_r2_soe: "win2012-r2-mb-app-${ENV:METABOX_GIT_BRANCH}"
    box_win16_soe:    "win2016-mb-app-${ENV:METABOX_GIT_BRANCH}"
    
    box_sql12:        "win2012-mb-bin-sql12-${ENV:METABOX_GIT_BRANCH}"
    box_sql12_r2:     "win2012-r2-mb-bin-sql12-${ENV:METABOX_GIT_BRANCH}"
    box_sql14:        "win2016-mb-bin-sql14-${ENV:METABOX_GIT_BRANCH}"
    box_sql16:        "win2016-mb-bin-sql16-${ENV:METABOX_GIT_BRANCH}"

    box_sp13_rtm:     "win2012-mb-bin-sp13-${ENV:METABOX_GIT_BRANCH}"
    box_sp13_r2:      "win2012-r2-mb-bin-sp13-${ENV:METABOX_GIT_BRANCH}"
    box_sp16:         "win2016-mb-bin-sp16-${ENV:METABOX_GIT_BRANCH}"

    custom_machine_folder: "${ENV:METABOX_WORKING_DIR}/vagrant_vms/metabox-soe-stacks"
  Resources:
    
    soe-win2012:
      Type: "vagrant::stack"
      Parameters:
        soe_box_name: "Fn::GetParameter box_win12_soe"
       
        dc_domain_name: "soe-win2012.local"
        dc_domain_admin_name: "admin"
        dc_domain_admin_password: "u8wxvKQ2zn"

        # SQL specific params
        sql_bin_path: "c:\\_metabox_resources\\sql2012sp2"
        sql_instance_name: "MSSQLSERVER"
        sql_instance_features: "SQLENGINE,SSMS,ADV_SSMS"

        # SharePoint specific settings
        sp_setup_user_name: "soe-win2012\\vagrant"
        sp_setup_user_password: "vagrant"

      Resources:
        dc:
          VagrantTemplate:
            - Type: "vagrant::config::vm"
              Properties:
                box: "Fn::GetParameter soe_box_name"

            - Type: "vagrant::config::vm::provider::virtualbox"
              Properties:
                cpus: 2
                memory: 512
                machinefolder: "Fn::GetParameter custom_machine_folder"

            - Type: "metabox::vagrant::host"
              Properties:
                hostname: "Fn::GetHostName"
```
### Fn::GetResourceHostName
This function looks up a host name of the other Vagrant virtual machine. Host name should be set by `Fn::GetHostName` for every virtual machine. However, sometimes we need to lookup a host name of other virtual machine, such as to connect SharePoint to SQL. That's why this function exists.

* Usage: "Fn::GetResourceHostName resource_name"

Below example uses "GetResourceHostName" to look up hostname of "sql" resource and pass it to "sp_first" resource. That's how host name of one resource can be passed between resources.

```yaml
Metabox:
  Description: Builds Vagrant VMs to trigger Vagrant box downloads
  Parameters:
    box_win12_soe:    "win2012-mb-app-${ENV:METABOX_GIT_BRANCH}"
    box_win12_app:    "win2012-mb-app-${ENV:METABOX_GIT_BRANCH}"

    box_win12_r2_soe: "win2012-r2-mb-app-${ENV:METABOX_GIT_BRANCH}"
    box_win16_soe:    "win2016-mb-app-${ENV:METABOX_GIT_BRANCH}"
    
    box_sql12:        "win2012-mb-bin-sql12-${ENV:METABOX_GIT_BRANCH}"
    box_sql12_r2:     "win2012-r2-mb-bin-sql12-${ENV:METABOX_GIT_BRANCH}"
    box_sql14:        "win2016-mb-bin-sql14-${ENV:METABOX_GIT_BRANCH}"
    box_sql16:        "win2016-mb-bin-sql16-${ENV:METABOX_GIT_BRANCH}"

    box_sp13_rtm:     "win2012-mb-bin-sp13-${ENV:METABOX_GIT_BRANCH}"
    box_sp13_r2:      "win2012-r2-mb-bin-sp13-${ENV:METABOX_GIT_BRANCH}"
    box_sp16:         "win2016-mb-bin-sp16-${ENV:METABOX_GIT_BRANCH}"

    custom_machine_folder: "${ENV:METABOX_WORKING_DIR}/vagrant_vms/metabox-soe-stacks"
  Resources:
    
    soe-win2012:
      Type: "vagrant::stack"
      Parameters:
        soe_box_name: "Fn::GetParameter box_win12_soe"
       
        dc_domain_name: "soe-win2012.local"
        dc_domain_admin_name: "admin"
        dc_domain_admin_password: "u8wxvKQ2zn"

        # SQL specific params
        sql_bin_path: "c:\\_metabox_resources\\sql2012sp2"
        sql_instance_name: "MSSQLSERVER"
        sql_instance_features: "SQLENGINE,SSMS,ADV_SSMS"

        # SharePoint specific settings
        sp_setup_user_name: "soe-win2012\\vagrant"
        sp_setup_user_password: "vagrant"

      Resources:
        dc:
          VagrantTemplate:
            - Type: "vagrant::config::vm"
              Properties:
                box: "Fn::GetParameter soe_box_name"

            - Type: "vagrant::config::vm::provider::virtualbox"
              Properties:
                cpus: 2
                memory: 512
                machinefolder: "Fn::GetParameter custom_machine_folder"

            - Type: "metabox::vagrant::host"
              Properties:
                hostname: "Fn::GetHostName"

            - Type: "metabox::vagrant::win12soe"
              Properties:
                execute_tests: false
        
            - Type: "metabox::vagrant::dc12"
              Properties:
                execute_tests: true
              
                dc_domain_name: "Fn::GetParameter dc_domain_name"
                dc_domain_admin_name: "Fn::GetParameter dc_domain_admin_name"
                dc_domain_admin_password: "Fn::GetParameter dc_domain_admin_password"
   
        client:
          VagrantTemplate:
            - Type: "vagrant::config::vm"
              Properties:
                box: "Fn::GetParameter soe_box_name"

            - Type: "vagrant::config::vm::provider::virtualbox"
              Properties:
                cpus: 2
                memory: 512
                machinefolder: "Fn::GetParameter custom_machine_folder"

            - Type: "metabox::vagrant::host"
              Properties:
                hostname: "Fn::GetHostName"
                synced_folder:
                  - src: "${ENV:METABOX_DOWNLOADS_PATH}/sql2012sp2"
                    dst: "c:\\_metabox_shared_resources\\sql2012sp2"
                    #dst: "c:\\_test"
                    type: "rsync"

            - Type: "metabox::vagrant::win12soe"
              Properties:
                execute_tests: false
         
            # - Type: "metabox::vagrant::dcjoin"
            #   Properties:
            #     execute_tests: true

            #     # dc specific parameters
            #     dc_domain_name: "Fn::GetParameter dc_domain_name"
            #     dc_join_user_name: "Fn::GetParameter dc_domain_admin_name"
            #     dc_join_user_password: "Fn::GetParameter dc_domain_admin_password"

        sql:
          VagrantTemplate:
            - Type: "vagrant::config::vm"
              Properties:
                box: "Fn::GetParameter box_sql12"

            - Type: "vagrant::config::vm::provider::virtualbox"
              Properties:
                cpus: 4
                memory: 4096
                machinefolder: "Fn::GetParameter custom_machine_folder"

            - Type: "metabox::vagrant::host"
              Properties:
                hostname: "Fn::GetHostName"
                # synced_folder:
                #   - src: "${ENV:METABOX_DOWNLOADS_PATH}"
                #     dst: "c:\\_metabox_shared_resources"
                #     type: "rsync"

            - Type: "metabox::vagrant::win12soe"
              Properties:
                execute_tests: true
         
            - Type: "metabox::vagrant::dcjoin"
              Properties:
                execute_tests: true

                # dc specific parameters
                dc_domain_name: "Fn::GetParameter dc_domain_name"
                dc_join_user_name: "Fn::GetParameter dc_domain_admin_name"
                dc_join_user_password: "Fn::GetParameter dc_domain_admin_password"

            - Type: "metabox::vagrant::sql12"
              Properties:
                execute_tests: true

                # SQL specific params
                sql_bin_path: "Fn::GetParameter sql_bin_path"
                sql_instance_name: "Fn::GetParameter sql_instance_name"
                sql_instance_features: "Fn::GetParameter sql_instance_features"
                sql_sys_admin_accounts:
                  - "vagrant"
                  - "soe-win2012\\vagrant"

        sp_first:
          VagrantTemplate:
            - Type: "vagrant::config::vm"
              Properties:
                box: "Fn::GetParameter box_sp13_rtm"

            - Type: "vagrant::config::vm::provider::virtualbox"
              Properties:
                cpus: 4
                memory: 6144
                machinefolder: "Fn::GetParameter custom_machine_folder"

            - Type: "metabox::vagrant::host"
              Properties:
                hostname: "Fn::GetHostName"

            - Type: "metabox::vagrant::win12soe"
              Properties:
                execute_tests: true
         
            - Type: "metabox::vagrant::dcjoin"
              Properties:
                execute_tests: true

                dc_domain_name: "Fn::GetParameter dc_domain_name"
                dc_join_user_name: "Fn::GetParameter dc_domain_admin_name"
                dc_join_user_password: "Fn::GetParameter dc_domain_admin_password"

            - Type: "metabox::vagrant::sp13-wfe"
              Properties:
                execute_tests: true

                # sharepoint specific settings
                sp_farm_sql_server_host_name: "Fn::GetResourceHostName sql"
                sp_farm_db_name: "Fn::GetResourceName"
                
                sp_farm_pass_phase: "Fn::GetParameter dc_domain_admin_password"

                sp_setup_user_name: "Fn::GetParameter sp_setup_user_name"
                sp_setup_user_password: "Fn::GetParameter sp_setup_user_password"
```


