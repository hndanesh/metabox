## Environment variables
Metabox uses a set of environment variables. They are used in two ways: within metabox documents, and within metabox itself. Below is a list of built-in variables which can be used:


### METABOX_SRC_PATH
A path to to metabox source folder. This should point to the root of the metabox repo. Comes handy in case we want to run metabox off a custom branch - simply check out various metabox branches into different folders, and then run metabox with the right METABOX_SRC_PATH value.

### METABOX_DOCUMENT_FOLDERS
Comma separated path to folders where metabox looks for ".metabox.yaml" documents. Metabox loads all documents from these giving folders.

### METABOX_WORKING_DIR
This is a folder where metabox will be storing all configurations, temporary files, logs and Packer/Vagrant related artefacts. This is the only folder where metabox leaves its foot-print in the system, no other folders are used.

First of all, metabox scopes Packer and Vagrant runs to METABOX_WORKING_DIR. It re-points vagrant/packer environment variables making them run "locally", within METABOX_WORKING_DIR folder only. That means that packer/vagrant will be "isolated" by metabox; it runs them re-pointing "VAGRANT_" and "PACKER_" environment variables making sure that these tools won't get out of METABOX_WORKING_DIR. That enables a better management of packer/vagrant and makes sure that images/boxes are scoped to a custom folder rater than being on a default system drive.

Secondly, metabox uses METABOX_WORKING_DIR for all operations. Essentially, here is how METABOX_WORKING_DIR looks like after metabox runs:

* .config
* .logs
* .vagrant
* metabox_branches
* metabox_downloads
* packer_boxes
* packer_cache
* packer_output
* packer_tmp
* vagrant_home
* vagrant_vms

### METABOX_LOG_LEVEL
This sets metabox log level:
* INFO
* DEBUG
* VERBOSE

### METABOX_GIT_BRANCH
Current branch on which metabox is run. This variable is heavily used within metabox documents to produce branch-specific images and virtual machines.

### METABOX_DOWNLOADS_PATH
A path where all files will be downloaded. Default value is "METABOX_WORKING_DIR/metabox_downloads"

### METABOX_DRY_RUN
If set, this make metabox to NOT RUN command but rather show them on the screen. Useful for debugging purposes.

### Vagrant/Packer specific variables
Metabox maps most of of Vagrant/Packer variables available from:
* https://www.packer.io/docs/other/environment-variables.html
* https://www.vagrantup.com/docs/other/environmental-variables.html

By default, metabox scopes packer/vagrant to METABOX_WORKING_DIR. These variables aren't really configurable for the ens-user. Instead, metabox manages packer/vagrant to be run in a local mode within METABOX_WORKING_DIR path.


## Minimal configurations for windows and mac:
Below is a minimal configurations which are needed is order to run metabox:

MacOS:

Following parameters should be saved in ".config.sh" file
```
# macos

METABOX_SRC_PATH="$(pwd)" \
METABOX_WORKING_DIR="~/__metabox_beta_working_dir" \
METABOX_DOCUMENT_FOLDERS="$(pwd)/documents,$(pwd)/documents_download,$(pwd)/documents_canary,$(pwd)/documents_stacks" \
METABOX_LOG_LEVEL="INFO" \
$1
```

Windows:

Following parameters should be saved in ".config.win.bat" file
```
# windows
SET "METABOX_SRC_PATH=%cd%"^
 && SET "METABOX_WORKING_DIR=H:/__metabox_beta_working_dir"^
 && SET "METABOX_DOCUMENT_FOLDERS=%cd%/documents,%cd%/documents_download,%cd%/documents_stacks"^
 && SET "METABOX_LOG_LEVEL=INFO"^
 && SET "METABOX_GIT_BRANCH=120-yaml-refactoring"
```

When it's done, run the command below in Cmder.
For macos:
```
clear && source .config.sh "rake"
```

For Windows
```
cls && .config.win.bat && rake resource:list
```