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

```

### Building Packer images

```bash
# soe image
cls && "config/.metabox.images.soe.bat" && rake resource:generate && rake resource:list  && rake packer:build[win2016-mb-soe,--force] && rake vagrant:add[win2016-mb-soe,--force] 

# app image
cls && "config/.metabox.images.soe.app.bat" && rake resource:generate && rake resource:list  && rake packer:build[win2016-mb-soe,--force] && rake vagrant:add[win2016-mb-soe,--force]

# 2016 RTM image
cls && "config/.metabox.images.sp16fp2.bat" && rake resource:generate && rake resource:list  && rake packer:build[win2016-mb-bin-sp16rtm,--force] && rake vagrant:add[win2016-mb-bin-sp16rtm,--force]

# 2016 FP2 image
cls && "config/.metabox.images.sp16fp2.bat" && rake resource:generate && rake resource:list  && rake packer:build[win2016-mb-bin-sp16fp2,--force] && rake vagrant:add[win2016-mb-bin-sp16fp2,--force]

```

### Building Vagrant VMs, contoso stack
```bash

# what's there?
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:status
# destroy all VMs which are there
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:destroy[_all,--force]

# provision DC, and client VMs joined to DC
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso-win2016::dc]
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso-win2016::client]

# provision VM with VS13 
# for VS15 a file resource needs to be downloaded before
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso-win2016::vs13]
cls && "config/.contoso.bat" && rake resource:generate && rake vagrant:up[contoso-win2016::vs15]

# proivision VM with SQL14
# for SQL14 a file resource needs to be downloaded before
cls && "config/.contoso.bat" && rake resource:generate && rake  vagrant:up[contoso-win2016::sql14]

# proivision a SharePoint farm
cls && "config/.contoso.bat" && rake resource:generate && rake  vagrant:up[contoso-win2016::sp_first]
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