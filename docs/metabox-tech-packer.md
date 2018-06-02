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



