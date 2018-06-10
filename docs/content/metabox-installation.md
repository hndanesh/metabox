# Installation

Metabox is an enhancement API layer on top of Packer/Vagrant tools to simplify machine image builds and Vagrant VMs management. It hides low-level details of Packer/Vagrant offering a consistent workflow to create, author and manage images and virtual machines.

![image](https://user-images.githubusercontent.com/11289124/32142667-df296fee-bcac-11e7-8336-ddd2c9c3da59.png)

It is written in Ruby and exposes a bunch of Rake tasks to manipulate Packer/Vagrant tools. All orchestration, such as file downloads, packaging/un-packaging, Packer builds and Vagrant VM provision is driven via "metabox documents" - YAML based configurations.

Being written in Ruby, metabox works well on MacOS and Windows platforms. In fact, it has been tested on Windows 2008, Windows 2016, Windows 10 and MacOS without major issues.

## Geting started 
Being an enhancement API layer on top of Packer/Vagrant, metabox requires several tools to be present in the PATH. Actual list of tools vary for the target platform, such as MacOS or Windows, but at glance looks as following:

**Macbook**
* brew (used to bootstrap other tools)
* git
* 7zip
* virtualbox
* packer
* vagrant
* iterm2 (not a metabox requirement but we install it as well)

**Windows**
* chocolatey (used to bootstrap other tools) 
* git
* 7zip
* virtualbox
* packer
* vagrant
* cmder (not a metabox requirement but we install it as well)

Apart this, metabox itself would install "sinatra" gem package to spin up HTTP web-server. This web-server exposes downloaded binaries to the Vagrant virtual machines. Currently, sinatra is used to expose a folder with files to vagrant VMs.

Here are 3 steps to get metabox installed:

### Step 1 - get source code
```
git clone https://github.com/subpointsolutions/metabox.git
```

### Step 2 - 3rd part tools bootatrap
Manual installation and validation of all prerequisites is a no-go. Hence, metabox ships "bootstrap" scripts for both MacOS and Windows platforms.

#### Mac
Run bootstrap-mac.sh.

#### Windows
1. Open `src` directory in cmd with administrative permissions.
2. Run `powershell .\bootstrap-windows.ps1`

You might receive following message:
```
The recent package changes indicate a reboot is necessary.
 Please reboot at your earliest convenience.
Exiting with non-zero code [3010] - Failed to install vagrant
Exiting with non-zero code [3010] - Failed to install vagrant
At D:\projects\metabox-beta\src\bootstrap-windows.ps1:28 char:9
+         throw "Exiting with non-zero code [$code] - $message"
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Exiting with no...install vagrant:String) [], RuntimeException
    + FullyQualifiedErrorId : Exiting with non-zero code [3010] - Failed to install vagrant
```
It's time to reboot the machine and run the procedure again to continue installation.
After installing remaining components you need to close the console and open it again.
You can run the bootstrap again to verify that the installation is fully complete:

![image](https://user-images.githubusercontent.com/11289124/34906908-7ad87794-f887-11e7-8830-67a2ba8f7e74.png)


### Step 3 - metabox config

Once done, you can continue with metabox configuration. All additional setup for vagrant and packer is done with metabox rake task. Metabox install the following tools and plugins:
* ruby gems: sinatra
* vagrant plugin: vagrant-hostmanager
* vagrant plugin: vagrant-reload
* vagrant plugin: vagrant-servrspec
* packer plugin: packer-builder-vagrant

Here is how to handle this:
```
# configure metabox dependencies, vagrant, packer
rake metabox:configure_metabox
rake metabox:configure_vagrant
rake metabox:configure_packer

# run all configuration tasks
# to be developed: rake metabox:configure_all

# validate cofiguration
rake metabox:validate_config

```

### Validate your metabox installation
Make sure that "rake metabox:validate_config" works well. It is meant to be a single point to validate metabox setup and configuration.

```
# validate cofiguration
rake metabox:validate_config

```

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