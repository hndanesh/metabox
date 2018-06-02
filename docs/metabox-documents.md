## Metabox documents overview
Metabox uses YAML as a markup language to define both Packer/Vagrant builds. Using the same document, you can define the following actions and things:

* files to download and where to place (plus pre/post download script hooks)
* Packer builds
* Vagrant VMs

The sole idea of "metabox document" is to have a single, self-contained way to define end-to-end build workflow - from file downloading, to Packer build, and then Vagrant VM provision. 

While YAML is a pretty static markup language, it does not play well with dynamic documents. That's why metabox offers parametrisation by adding two things into YAML documents:
* tokens 
* functions  

Tokens are simply "string replacements", such as "environment variable replacement", and "functions" are powerful way to parametrise YAML sections and lookup values from other YAML sections.

Altogether, metabox YAML document not only offers end-to-end workflow to download files and execute Packer/Vagrant but also enables parametrisation and parameters lookups. Parametrisation is an important concept in metabox. By using parameters we can reduce amount of changes done to a YAML, reduce "magic strings" and bring "blue/green" deployment concept into image creation and VM provision world; simply saying, we can "branch" everything we build by adding "current branch" prefix/postfix into the right place in YAML. That way, we can build "master" images and VMs, and then build any "feature branch" image and VMs same way without interfering with already built resources. Your documents, however, remain the same; parameterisation is the driver behind all this.

## Metabox document anatomy
Metabox documents are valid YAML files which:
* end with ".metabox.yaml"
* define one or more "resources" (such as file download, Packer build or Vagrant VM)

At some sense, document looks similar to AWS CloudFormation templates: top level "Metabox" section, then Description and "Resource" section which houses one or many resources. Each resource had got "Type" and "Properties". Metabox then parses document and calls appropriate actions for every "resource" as per its type.

Below is an example on how metabox defines a Packer build to create centos7-base image with java8 installed. Check further documentation on how it all works.

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

Let's build a metabox document from scratch handling three areas:
* downloading files
* build packer images
* building vagrant VMs

Empty metabox document:
```yaml
Metabox:
  Description: Builds SharePoint 2013 farm
  
  Parameters:
    box_name: "win2012-mb-app"
   
  Resources:
     MyResource1:
        Type: "ResourceType"
        Properties: 
       
     MyResource2:
        Type: "ResourceType"
        Properties: 
```

Things to know:
* Top section "Metabox" can have:
  * "Description" to define what this document is about
  * "Parameters" - every section can have this name-value hash
  * "Resources" - one or many resources which have "Type" and "Properties"

Every resource under "Resource" should have two properties - "Type" and "Properties". Metabox later parses it and runs actions as per type and properties for every resource. Here are available resources:

* `"metabox::http::file_set` -> a set of files to download
* `metabox::packer::build` -> Packer build
* `"vagrant::stack` -> a set of Vagrant VMs

Here is a simple document to download files and place them into a folder:

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

Here is a metabox document to build packer image:

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


Here is metabox document to build Vagrant VMs (a stack of them)

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

There are several concepts around how these documents work - tokens and functions.

#### Tokens 
Tokens are simply string replacements. Currently, there is only `${ENV:VARIABLE_NAME}` token which replaces an environment variable in a string:
```yaml
Document:
    MyValue: "${ENV:METABOX_WORKING_DIR}/vagrant_vms/metabox_boxes"
```

If you want to replace the whole section, it can be done as following:
```yaml
Document:
    "MyValue${ENV:METABOX_GIT_BRANCH}": "${ENV:METABOX_WORKING_DIR}/vagrant_vms/metabox_boxes"
```