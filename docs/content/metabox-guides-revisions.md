This section is more of a practical guide on how "revisions" or partial provision works in metabox with some hands-on experience and manuals.

If you want to know more about particular metabox areas, then it might be better to check out the documentation on the right. This guide is a mix of a particular command and setups to get stuff working fast. Broader documentation is available in other articles.

## Vagrant partial provision with Metabox
Metabox orchestrates Packer/Vagrant tools via YAML based documents. While normally you would write Ruby-based DSL for Vagrant VMs, with metabox you use YAML to configure scripts to be run against target VM.

Windows infrastructure automation often comes with heavy installations, reboots and other time-consuming operations. Sometimes, they have to be done once (such as joining to domain controller) but the way Vagrant works out of the box is that it's either "run all scripts" or "run no scripts". Hence, if we want to run only a particular script skipping others, an additional configuration has to be implemented.

Metabox solves this. It provides "partial provision", so-called "revisions" to enable provision of custom configurations. The way it works is that metabox abstracts Vagrant shell/powershell provisioners allowing to disable/enable them upon condition. In turn, that allows scoping and selecting which provision to run.

Consider the following scenario:
* metabox delivers base infrastructure and setup for SharePoint 2013/2016
* you apply your own PowerShell or DSC scripts on top without changing metabox documents

## Defining "revisions"
Metabox "revision" is still a valid YAML document. The very idea of revisions is that:
* you don't have to change original document shipped with metabox
* you write your own document with things you would like to run against VMs
* you "attach", "target" your provision against VMs

That way we separate heavy infrastructure provision from light, application specific provision on top. The strategy is to have "almost-never-changing" document for infrastructure (such as DC + SQL + SharePoint), and then have other documents to define "custom" provision on top. 

Not only that separates heavy provision from ever changing additions on top but also help to safely pull the latest sources from the metabox repo. Consider that metabox provides a core infrastructure documents, and then you can provision your customizations, tools and app on top.

We ship several revision documents under `contoso_revisions` folder. Here is a simple revision which runs a PowerShell DSC script:

```yaml
Metabox:
  Description: "Revisions for contoso stack, deploys a test folder to all VMs in a stack"
  Resources:
    
    revision-folders:
      Type: "vagrant::revision"
      Name: "test folder deployment"
      Tags: [ 'revision' ]
      
      TargetResource:
        - MatchType :  "name"
          Values    : [ "soe-win2012-r2::*" ]
        
        - MatchType : "tag"
          Values    : [ "*" ]

      Parameters:
    
      VagrantTemplate:
        - Type: "metabox::vagrant::shell"
          Name: "Revision folders"
          Tags: [ "revision", "my_folders" ]
          Properties:
            path: "./scripts/folders/folders.dsc.ps1"
```

A few things to know:
* TargetResource section scopes how this revision going to be applied to VMs
* TargetResource supports wildcard name match
* TargetResource supports tags to match - either array of tags or "*"

As this is still a normal metabox document, you can use `VagrantTemplate` section to configure your scripts to be run. Name/tag matching makes it possible to attach revision to one or many VMs.

## Applying "revisions"
By default, metabox has disabled "revision" feature. It may change in the future releases but for the time being, set `METABOX_FEATURES_REVISIONS` variable to anything. Check `.contoso.revisions.bat` config to see how it works. Setting this variable would enable revisions feature in metabox so that it would be able to pick revisions and run partial provision.

Next, use the following syntax to apply your revisions:

```bash
cls && "config/.metabox.revisions.bat" && rake resource:generate && rake vagrant:up[contoso-win2012-r2::dc,--provision,provision_tags=my_folders]
```

By running this, you instruct metabox to do the following flow:
* process all YAML documents
* match revision Name/Tags against VMs
* Vagrant provision with `--force` flag
* run anything that has got "my_folders" value in `Tags` section

This revision targets all VMs in "soe-win2012-r2::*" stack with all tags "*".

Checkout `dev-tooling.metabox.yaml` document under `contoso_revisions`. This revision install additional development tooling to support SharePoint development. It target all VMs which have tag "vs13", and can be run as this:

```bash
cls && "config/.metabox.revisions.bat" && rake resource:generate && rake vagrant:up[contoso-win2012-r2::vs13,--provision,provision_tags=dev-tooling]
```

```yaml
Metabox:
  Description: "Revisions for contoso stack, deploys development tooling to 'vs13' tagged VMs"
  Resources:
    
    dev-tooling:
      Type: "vagrant::revision"
      Name: "dev-tooling"
      Tags: [ 'revision' ]
      
      TargetResource:
        - MatchType : "tag"
          Values    : [ "vs13" ]

      VagrantTemplate:
        - Type: "metabox::vagrant::shell"
          Tags: [ "revision", "dev-tooling" ]
          Name: "Revision dev-tooling"
          Properties:
            path: "./scripts/dev-tooling/dev-tools.dsc.ps1"
```


## Revision hints

Use the following `TargetResource` config with "*" tags targeting to apply revision to all VMs across stacks:
```yaml
Metabox:
  Description: "Revisions for contoso stack, deploys development tooling to 'vs13' tagged VMs"
  Resources:
    
    dev-tooling:
      Type: "vagrant::revision"
      Name: "dev-tooling"
      Tags: [ 'revision' ]
      
      TargetResource:
        - MatchType : "tag"
          Values    : [ "*" ]

      VagrantTemplate:
        - Type: "metabox::vagrant::shell"
          Tags: [ "revision", "dev-tooling" ]
          Name: "Revision dev-tooling"
          Properties:
            path: "./scripts/dev-tooling/dev-tools.dsc.ps1"
```

Use "+" separator to execute several revisions against target VM:

```bash
cls && "config/.metabox.revisions.bat" && rake resource:generate && rake vagrant:up[contoso-win2012-r2::vs13,--provision,provision_tags=dev-tooling+my_folders+something_else]
```

