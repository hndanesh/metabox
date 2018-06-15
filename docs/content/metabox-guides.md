# Guides

This section describes stack-specific guide to get metabox setup and provision win2012/win2012-r2 or win2016 stacks. 

Check out particular guide to get images and VMs built.


This section is more of a practical guide to get metabox installed and provision win2012-r2 stack with DC, SQL and SharePoint VMs. 

If you want to know more about particular metabox areas, then it might be better to check out the documentation on the right. This guide is a mix of a particular command and setups to get stuff working fast. Broader documentation is available in other articles.

## Metabox installation 
Broad documentation can be found here:
> https://github.com/subpointsolutions/metabox/wiki/metabox-installation

Metabox itself is a Ruby-based application which orchestrates Packer/Vagrant tools via YAML based documents. It might be a good idea to familiarise yourself with these tools before getting into metabox:
* https://www.packer.io/intro/index.html
* https://www.vagrantup.com/docs/index.html

Currently, we provide metabox as a bunch of Ruby code and CLI interface. Metabox was tested and works well on MacOS, Windows 2008, Windows 2016, Windows 10. 

Below is a minimal path to awesomeness for windows users, but if you are on MacBook, then just use corresponding `sh` scripts.

```bash
# get source code
git clone https://github.com/SubPointSolutions/metabox.git

# go to src folder
cd src

# bootstrap 3rd part tools, this would use dry-run to show what's installed and what's not 
powershell .\bootstrap-windows.ps1

# if tools are missed, install them manually or with --provision flag
powershell .\bootstrap-windows.ps1 --provision
```

Note that we use VirtualBox 5.1.22 as it was proven to work well with Packer/Vagrant across Win/Mac platforms. The latest versions of VirtualBox might not work well.

### Updating to the latest
SharePoint 2016 support comes with `0.1.1` version which has not been merged to master yet. Hence, pull the latest from git like this:

```bash
git fetch --all
git checkout 0.1.1
git pull
```

Normally, you would use `master` branch as this:
```bash
git fetch --all
git checkout master
git pull
```

Once done, don't forget to change current dir to `\src` and hit the version task. Optionally, check other tasks provided by metabox:
```bash
rake metabox:version
rake -T
```

## Metabox stacks: validation and canary boxes
Once 3rd part tools are done, let's configure metabox itself:

```bash
# configure metabox dependencies, vagrant, packer
cls && "config/.contoso.canary.bat "&& rake metabox:configure_metabox
cls && "config/.contoso.canary.bat" && rake metabox:configure_vagrant
cls && "config/.contoso.canary.bat" && rake metabox:configure_packer

# validate cofiguration
cls && "config/.contoso.canary.bat" && rake metabox:validate_config
```

Once done, we might try to build so-called "canary" Vagrant boxes - a set of Vagrant boxes to ensure that the whole setup works. Here is how it can be done:

```bash
# delete all VMs
cls && "config/.contoso.canary.bat" && rake resource:generate && rake resource:list && rake vagrant:destroy[soe-canary::_all,--force]

# create win2012 Vagrant box
cls && "config/.contoso.canary.bat" && rake resource:generate && rake resource:list && rake vagrant:up[soe-canary::win2012]

# create win2012-r2 Vagrant box
cls && "config/.contoso.canary.bat" && rake resource:generate && rake resource:list && rake vagrant:up[soe-canary::win2012-r2]

# create centos7 Vagrant box
cls && "config/.contoso.canary.bat" && rake resource:generate && rake resource:list && rake vagrant:up[soe-canary::centos7]

# create hashicorp precise64 Vagrant box
cls && "config/.contoso.canary.bat" && rake resource:generate && rake resource:list && rake vagrant:up[soe-canary::precise64]

# stand up ALL vagrant boxes back to back
cls && "config/.contoso.canary.bat" && rake resource:generate && rake resource:list && rake vagrant:up[soe-canary::_all]

```

Make sure all of these VMs work. If they don't work, the initial configuration is wrong. It might be VirtualBox, Packer/Vagrant, or metabox itself.

## Metabox win2012-r2 stacks
A metabox stack is a set of Vargant boxes (virtual machines) put together into the same network. That way, we can spin up an isolated domain controller, then join other machines to the domain. Metabox also manages networking, IPs and a lot of other low-level stuff.

Before building VMs, we need to download additional media (patches, installation media), and then build Packer images. With win2012-r2 stack, we build several Packer images and then set up a "Contoso" stack - a set of virtual machines with different roles:
* domain controller
* a client joined to dc
* sql12 server machine
* dev machine with Visual Studio 2013/2015
* SharePoint 2013 SP 1

Here is the strategy behind file downloads, Packer/Vagrant:
* We download required software: patches, installation media and so on
* We build Packer images: basic image ("SOE"), then "app" image, and then "bin-sp13" image
* We build Vagrant VMs with particular roles: dc, sql, sharepoint and so on

### Downloading installation media and patches
First of all, we need to download heavy installation media and patches to make sure we can build Packer images.

Here is how it can be done:
```bash
cls && "config/.metabox.downloads.bat" && rake resource:generate && rake resource:list  && rake fileset:download[KB::KB2919355-2012r2] 

cls && "config/.metabox.downloads.bat" && rake resource:generate && rake resource:list  && rake fileset:download[KB::KB2919442-2012r2]


```

Check `/documents/metabox_downloads` folder to see what are other "file resources" you can download. For instance, here are SQL12 and VS2013:


```bash
cls && "config/.metabox.downloads.bat" && rake resource:generate && rake resource:list  && rake fileset:download[sql::sql2012sp2]
 
cls && "config/.metabox.downloads.bat" && rake resource:generate && rake resource:list  && rake fileset:download[visualstudio::vs2013.5_ent_enu]


```

Metabox will use information in "metabox document" under `/documents/metabox_downloads` folder to figure out available file resources. Then it uses `wget` to download files, ensure checksum, and then it used `7zip` to split everything into zip archives with multiple files of 500Mb each. All goes to `METABOX_WORKING_DIR/metabox_downloads`, there is a structure, a name convention for file resources. 

This is important because metabox used a name convention and 500Mb file archives to transfer these files (huge ISO and installation media) to Packer/Vagrant boxes.

For win2012-r2 stack, you'd need to get KB2919355/KB2919442, and then sql2012sp2/vs2013.5_ent_enu file sresources downloaded.

### Adding your SharePoint 2013 SP1 ISO to metabox
If you got to this point, you should know that SharePoint 2013 SP1 isn't publically available. We can't download it, and unfortionatly this is where you should do some manual setup.

1) Get your SharePoint 2013 ISO downloaded from MSDN subscription
2) Put it under `METABOX_WORKING_DIR/metabox_downloads/sp2013sp1`

It should be something like this:
>  METABOX_WORKING_DIR/metabox_downloads/sp2013sp1/my-sharepoint-msdn-image.iso

3) Go to r `METABOX_WORKING_DIR/metabox_downloads/sp2013sp1` folder, and then run this:
> 7z -v500m a zip/dist.zip my-sharepoint-msdn-image.iso

You should end up with the following folder structure:
```
METABOX_WORKING_DIR/metabox_downloads/sp2013sp1/my-sharepoint-msdn-image.iso
METABOX_WORKING_DIR/metabox_downloads/sp2013sp1/zip
METABOX_WORKING_DIR/metabox_downloads/sp2013sp1/zip/dist.zip.001
METABOX_WORKING_DIR/metabox_downloads/sp2013sp1/zip/dist.zip.002
METABOX_WORKING_DIR/metabox_downloads/sp2013sp1/zip/dist.zip.003
METABOX_WORKING_DIR/metabox_downloads/sp2013sp1/zip/dist.zip.004
METABOX_WORKING_DIR/metabox_downloads/sp2013sp1/zip/dist.zip.005
```

4) Finally, update `.metabox.images.sp13sp1.bat` with your SharePoint 2013 SP1 product key:
```bash
SET "METABOX_SRC_PATH=%cd%"^
 && SET "METABOX_WORKING_DIR=%cd:~0,3%/__metabox_beta_working_dir"^
 && SET "METABOX_DOCUMENT_FOLDERS=%cd%/documents/metabox_images_sp13_sp1"^
 && SET "METABOX_LOG_LEVEL=INFO"^
 && SET "METABOX_SP13_SP1_PRODUCT_KEY=YOUR_SP13_SP1_PRODUCT_KEY_HERE"
```

Here we go! Now you can build Packer image with pre-installed SharePoint binaries, and then get all Vagrant VMs done.

### Building Packer images
Most of the time, there are 3 types of Packer images we build for win2012-r2 stack. 
* "soe" image: basic installs, PS, PS DSC modules, 7zip, patches
* "app" image: app-specific patches, heavy patches, additional windows features
* "bin_sp13" image: pre-installed SharePoint binaries (required SharePoint product key!)
> SOE stands for "Standard Operating Environment"

Packer image is a pre-configured virtual machine image which can later be re-used for other Packer build or Vagrant virtual machine creation. The very idea is that we build images based on other images, and that way we don't have to install all the heavy patches all the time. Here is metabox flow:
> soe image -> app image -> bin_sp13 image

SOE installs a minimal set of tools and software, patches. Then we build "app" specific image on top of "soe" image so that we don't have to start from scratch. Later, we add "bin_sp13" image on top of "app" image focusing only on SharePoint binary installs (all things are already done and configured by "soe" and "app" images).

Here is how we can build them:
```bash
# soe image
cls && "config/.metabox.images.soe.bat" && rake resource:generate && rake resource:list  && rake packer:build[win2012-r2-mb-soe,--force] && rake vagrant:add[win2012-r2-mb-soe,--force] 

# app image
cls && "config/.metabox.images.soe.app.bat" && rake resource:generate && rake resource:list  && rake packer:build[win2012-r2-mb-app,--force] && rake vagrant:add[win2012-r2-mb-app,--force]

# hey, SharePoint product key is required here
# update .metabox.images.sp13sp1.bat file!!!
cls && "config/.metabox.images.sp13sp1.bat" && rake resource:generate && rake resource:list  && rake packer:build[win2012-r2-mb-bin-sp13,--force] && rake vagrant:add[win2012-r2-mb-bin-sp13,--force]


```

### Building Vagrant VMs, contoso stack
Once Packer images are done, we can build Vagrant VMs which are based on these images. Piece of cake!

```bash
# what's there?
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:status
# destroy all VMs which are there
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:destroy[_all,--force]

# provision DC, and client VMs joined to DC
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso-win2012-r2::dc]
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso-win2012-r2::client]

# provision VM with VS13 
# for VS15 a file resource needs to be downloaded before
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso-win2012-r2::vs13]
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso-win2012-r2::vs15]

# proivision VM with SQL12
# for SQL14 a file resource needs to be downloaded before
cls && "config/.contoso.bat" && rake resource:generate && rake  vagrant:up[contoso-win2012-r2::sql12]
cls && "config/.contoso.bat" && rake resource:generate && rake  vagrant:up[contoso-win2012-r2::sql14]

# proivision a SharePoint farm
cls && "config/.contoso.bat" && rake resource:generate && rake  vagrant:up[contoso-win2012-r2::sp13_first]


```

### What's next?
Check your output, you would see the following trace which you can use to ssh/rdp to your VMs. Alternatively, just double-click on VM in VirtualBox UI.

Use `soe-win2012-r2\\vagrant` user with password `vagrant` - these are out of the box coming from Vagrant.

```bash
2018-01-24 17:40:50 +1100 INFO Finished running cmd with result: [true]
2018-01-24 17:40:50 +1100 WARN Finished configuring host: contoso-win2012-r2-sp13_first
2018-01-24 17:40:50 +1100 WARN !!! use information below to ssh/rdp to this host !!!
2018-01-24 17:40:50 +1100 INFO   hostname:   mb-cnwpronqrk
2018-01-24 17:40:50 +1100 INFO   host_ip:    192.168.9.13
2018-01-24 17:40:50 +1100 INFO   gateway_ip: 192.168.9.1
2018-01-24 17:40:50 +1100 INFO   hostnames:
2018-01-24 17:40:50 +1100 INFO       - mb-cnwpronqrk
2018-01-24 17:40:50 +1100 INFO       - contoso-win2012-r2-sp13_first
2018-01-24 17:40:50 +1100 WARN !!! --------------------------------------------- !!!
```




## Windows 2016

This section is more of a practical guide to get metabox installed and provision win2016 stack with DC, SQL and SharePoint VMs.

If you want to know more about particular metabox areas, then it might be better to check out the documentation on the right. This guide is a mix of a particular command and setups to get stuff working fast. Broader documentation is available in other articles.

We skip all initial installation steps assuming that you have already working metabox installation. If not, check installation guides on the left or just use these link:
* https://github.com/subpointsolutions/metabox/wiki/metabox-installation
* https://github.com/subpointsolutions/metabox/wiki/metabox-guides-win2012-r2

### Updating to the latest
SharePoint 2016 support comes with `0.1.1` version which has not been merged to master yet. Hence, pull the latest from git like this:

```bash
git fetch --all
git checkout 0.1.1
git pull
```

Normally, you would use `master` branch as this:
```bash
git fetch --all
git checkout master
git pull
```

Once done, don't forget to change current dir to `\src` and hit the version task. Optionally, check other tasks provided by metabox:
```bash
rake metabox:version
rake -T
```

### Metabox win2016 stacks

A metabox stack is a set of Vargant boxes (virtual machines) put together into the same network. That way, we can spin up an isolated domain controller, then join other machines to the domain. Metabox also manages networking, IPs and a lot of other low-level stuff.

With Windows 2016 stack we need to build 4 packer images:
* base soe image
* base app image
* SharePoint 2016 RTM image
* SharePoint 2016 Feature Pack 2 image

We would also need to download SQL14, SharePoint 2016 RTM and Feature2 Pack distributives. Happily, all this is automated.

### Downloading SharePoint 2016 RTM and FP2

```bash
# download SQL14
cls && "config/.metabox.downloads.bat" && rake resource:generate && rake resource:list  && rake fileset:download[sql::sql2014sp1]

# download SharePoint 2016 RTM and FP2
cls && "config/.metabox.downloads.bat" && rake resource:generate && rake resource:list  && rake fileset:download[sp2016::sp2016server_rtm]

cls && "config/.metabox.downloads.bat" && rake resource:generate && rake resource:list  && rake fileset:download[sp2016::sp2016_fp2]

cls && "config/.metabox.downloads.bat" && rake resource:generate && rake resource:list  && rake fileset:download[visualstudio::vs2017.vs_enterprise.exe]

```

### Building Packer images

```bash
# soe image
cls && "config/.metabox.images.soe.bat" && rake resource:generate && rake resource:list && rake packer:build[win2016-mb-soe,--force] && rake vagrant:add[win2016-mb-soe,--force] 

# app image
cls && "config/.metabox.images.soe.app.bat" && rake resource:generate && rake resource:list && rake packer:build[win2016-mb-app,--force] && rake vagrant:add[win2016-mb-app,--force]

# 2016 RTM image
cls && "config/.metabox.images.sp16fp2.bat" && rake resource:generate && rake resource:list && rake packer:build[win2016-mb-bin-sp16rtm,--force] && rake vagrant:add[win2016-mb-bin-sp16rtm,--force]

# 2016 FP2 image
cls && "config/.metabox.images.sp16fp2.bat" && rake resource:generate && rake resource:list && rake packer:build[win2016-mb-bin-sp16fp2,--force] && rake vagrant:add[win2016-mb-bin-sp16fp2,--force]

```

### Building Vagrant VMs, contoso stack
```bash

# what's there?
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:status
# destroy all VMs which are there
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:destroy[_all,--force]

# provision DC, and client VMs joined to DC
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso16::dc]
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso16::client]

# provision VM with VS17 
# for VS15 a file resource needs to be downloaded before
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso16::vs13]

# proivision VM with SQL14
# for SQL14 a file resource needs to be downloaded before
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso16::sql14]

# proivision a SharePoint farm
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso16::sp16_fp2]
```

### What's next?
Check your output, you would see the following trace which you can use to ssh/rdp to your VMs. Alternatively, just double-click on VM in VirtualBox UI.

Use `soe-win2016\\vagrant` user with password `vagrant` - these are out ogf the box coming from Vagrant.

```bash
2018-01-24 17:40:50 +1100 INFO Finished running cmd with result: [true]
2018-01-24 17:40:50 +1100 WARN Finished configuring host: contoso-win2016-sp_first
2018-01-24 17:40:50 +1100 WARN !!! use information below to ssh/rdp to this host !!!
2018-01-24 17:40:50 +1100 INFO   hostname:   mb-cnwpronqrk
2018-01-24 17:40:50 +1100 INFO   host_ip:    192.168.9.13
2018-01-24 17:40:50 +1100 INFO   gateway_ip: 192.168.9.1
2018-01-24 17:40:50 +1100 INFO   hostnames:
2018-01-24 17:40:50 +1100 INFO       - mb-cnwpronqrk
2018-01-24 17:40:50 +1100 INFO       - contoso-win2016-sp_first
2018-01-24 17:40:50 +1100 WARN !!! --------------------------------------------- !!!
```