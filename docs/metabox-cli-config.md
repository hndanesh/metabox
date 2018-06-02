## Minimal configurations
It is recommended to create a few config files, define variables there, and then source them before running metabox itself. Here is how it can be done:

macos, .config.sh
```
METABOX_SRC_PATH="$(pwd)" \
METABOX_WORKING_DIR="~/__metabox_beta_working_dir" \
METABOX_DOCUMENT_FOLDERS="$(pwd)/documents,$(pwd)/documents_download,$(pwd)/documents_canary,$(pwd)/documents_stacks" \
METABOX_LOG_LEVEL="INFO" \
$1
```

Windows, .config.bat
```
# windows
SET "METABOX_SRC_PATH=%cd%"^
 && SET "METABOX_WORKING_DIR=H:/__metabox_beta_working_dir"^
 && SET "METABOX_DOCUMENT_FOLDERS=%cd%/documents,%cd%/documents_download,%cd%/documents_stacks"^
 && SET "METABOX_LOG_LEVEL=INFO"^
 && SET "METABOX_GIT_BRANCH=120-yaml-refactoring"
```

Once these files are created, you can run metabox as this:
```
# macos
clear && source .config.sh "rake"
# windows
cls && .config.win.bat && rake 
```

Multiple commands can be ru as this:
```
# macos
clear && source .config.sh "rake resource:generate resource:list"
# windows
cls && .config.win.bat && rake resource:generate && rake resource:list 
```
