MetaboxResource.define_config("win2012-r2-mb-app") do | metabox |

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir
  download_dir = metabox.env.get_metabox_downloads_path

  custom_machine_folder = "#{working_dir}/vagrant_vms/metabox_canary_win2016"

  box_name             = "win2012-r2-mb-soe-#{git_branch}"
  skip_windows_updates = true

  metabox.description = "Builds Windows 2012R2 app image"

  metabox.define_packer_build("win2012-r2-mb-app") do | packer_build |

    packer_build.packer_file_name = "win2012-r2-mb-app.json"
    packer_build.vagrant_box_name = "win2012-r2-mb-app-#{git_branch}"

    packer_build.define_packer_template do | packer_template |
     
      packer_template.builders << {
        "Type" => "packer::builders::vagrant_win12_sysprep",
        "Properties" => {
          "box_name" => box_name,
          "builder" => {
            "output_directory" => "#{working_dir}/packer_output/win2012-r2-mb-app-#{git_branch}",
            "http_directory" => download_dir
          }
        }
      }

     # vagrant_win12_sysprep support files
      packer_template.provisioners << { 
        "type" => "file",
        "source" => "./scripts/packer/metabox.packer.core/answer_files/2012_r2/Autounattend_sysprep.xml",
        "destination" => "c:/Windows/Temp/Autounattend_sysprep.xml"
      }

      # re-ensuring PowerShell modules
      # that helps to avoid SOE rebuild
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_install-dsc-modules.ps1"
        ]
      }

      # Configuring Windows to install updates from online source
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_configure-update-source.ps1"
        ],
        "environment_vars" => [
          "METABOX_DSC_CHECK=1"
        ]
      }

      # NET core install and reboot
      # two hits with METABOX_DSC_CHECK=1 flag to mitigate glitches
      # installing it first as it may hang and fail while installing via Internet
      # if so, then we won't wait a lot of time while installing further updates
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_install-netcore-feature.ps1"
        ],
        "pause_before": "5m"
      }
      packer_template.provisioners << { 
        "type" => "windows-restart"
      }
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_install-netcore-feature.ps1"
        ],
        "environment_vars" => [
          "METABOX_DSC_CHECK=1"
        ]
      }

      # installing kb2919355, required by VS2015 to be installed
      # This version of Visual Studio requires the April 2014 update to Windows 8.1 and Windows Server 2012 R2 known as 
      # !$!http://go.microsoft.com/fwlink/?LinkId=403643&clcid=0x409!,!KB 2919355!@!. 

      # we install two updates KB2919442, and then KB2919355
      # KB2919355 is around 700Mb, hence we make it installed 'offline' out of meabox file resources
      # overwise we loose ability to install VS2015 on win2012-r2
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_metabox_dist_helper.ps1"
        ],
        "environment_vars" => [
          "METABOX_RESOURCE_NAME=KB2919355-2012r2"
        ]
      }
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_metabox_dist_helper.ps1"
        ],
        "environment_vars" => [
          "METABOX_RESOURCE_NAME=KB2919442-2012r2"
        ]
      }
      # '0x80240017' hex code to int value -> 2149842967
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_metabox_install_package.ps1"
        ],
        "environment_vars" => [
          "METABOX_APP_PACKAGE_NAME=KB2919442",
          "METABOX_APP_PACKAGE_FILE_PATH=C:\\_metabox_resources\\KB2919442-2012r2\\Windows8.1-KB2919442-x64.msu",
          "METABOX_APP_PACKAGE_SILENT_ARGS=/quiet /norestart /log:c:\\windows\\TEMP\\KB2919442.Install.evt",
          "METABOX_APP_PACKAGE_EXIT_CODES=0,3010,2149842967"
        ],
        "valid_exit_codes" => [ 0, 3010 ]
      }
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_metabox_install_package.ps1"
        ],
        "environment_vars" => [
          "METABOX_APP_PACKAGE_NAME=KB2919355",
          "METABOX_APP_PACKAGE_FILE_PATH=C:\\_metabox_resources\\KB2919355-2012r2\\Windows8.1-KB2919355-x64.msu",
          "METABOX_APP_PACKAGE_SILENT_ARGS=/quiet /norestart /log:c:\\windows\\TEMP\\KB2919355.Install.evt",
          "METABOX_APP_PACKAGE_EXIT_CODES=0,3010,2149842967"
        ],
        "valid_exit_codes" => [ 0, 3010 ]
      }
      packer_template.provisioners << { 
        "type" => "windows-restart",
        "restart_timeout" => "15m"
      }
      # installing kb2919355 -- end

      # install other features required by SharePoint 2013
      # we aim to cur time required to prepare SharePoint bin box
      # two hits to ensure all glitches 
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_install-sp13-features.ps1"
        ]
      }
      packer_template.provisioners << { 
        "type" => "windows-restart",
        "restart_timeout" => "15m"
      }
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_install-sp13-features.ps1"
        ]
      }
      packer_template.provisioners << { 
        "type" => "windows-restart",
        "restart_timeout" => "15m"
      }

      # installing additional packages
      # these will be used to simplify VS setup and installs later on
      packer_template.provisioners << { 
        "type" => "powershell",
        "inline" => [
          "Write-Host 'Installing Web Platform Installer...'",
          "choco install -y webpicmd"
        ]
      }

      if !skip_windows_updates
        # installing updates
        packer_template.provisioners << { 
          "type" => "powershell",
          "inline" => [
            "Write-Host 'Installing updates...'",
            "Get-WUInstall -WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot"
          ]
        }
      end

      # additional reboot to get all updates applied
      packer_template.provisioners << { 
        "type" => "windows-restart",
        "restart_timeout" => "45m"
      }

      packer_template.post_processors << {
        "Type" => "packer::post-processors::vagrant",
        "Properties" => {
          "output": "#{working_dir}/packer_boxes/win2012-r2-mb-app-#{git_branch}-{{.Provider}}.box"
        }
      }
      
    end

  end

end