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

