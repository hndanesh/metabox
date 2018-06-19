MetaboxResource.define_config("win2016-mb-app") do | metabox |

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir
  download_dir = metabox.env.get_metabox_downloads_path

  custom_machine_folder = "#{working_dir}/vagrant_vms/metabox_canary_win2016"

  box_name             = "win2016-mb-soe-#{git_branch}"
  skip_windows_updates = true

  metabox.description = "Builds Windows 2016 app image"

  metabox.define_packer_build("win2016-mb-app") do | packer_build |

    packer_build.packer_file_name = "win2016-mb-app.json"
    packer_build.vagrant_box_name = "win2016-mb-app-#{git_branch}"

    packer_build.define_packer_template do | packer_template |
     
      packer_template.builders << {
        "Type" => "packer::builders::vagrant_win16_sysprep",
        "Properties" => {
          "box_name" => box_name,
          "builder" => {
            "guest_additions_mode" => "attach",
            "communicator" => "winrm",
            "winrm_username" => "vagrant",
            "winrm_password" => "vagrant",
            "winrm_timeout" => "12h",
            "output_directory" => "#{working_dir}/packer_output/win2016-mb-app-#{git_branch}",
            "http_directory" => download_dir
          }
        }
      }

      # supporting files for sysprep 2016
      packer_template.provisioners << { 
        "type" => "file",
        "source" => "./scripts/packer/metabox.packer.core/win2016/run-sysprep.cmd",
        "destination" => "c:/run-sysprep.cmd"
      }
      packer_template.provisioners << { 
        "type" => "file",
        "source" => "./scripts/packer/metabox.packer.core/win2016/run-sysprep.ps1",
        "destination" => "c:/run-sysprep.ps1"
      }
      packer_template.provisioners << { 
        "type" => "file",
        "source" => "./scripts/packer/metabox.packer.core/answer_files/2016/Autounattend_sysprep.xml",
        "destination" => "c:/Autounattend_sysprep.xml"
      }

      # re-ensuring PowerShell modules
      # that helps to avoid SOE rebuild
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_install-dsc-modules.ps1"
        ]
      }

      # NET core install and reboot
      # two hits with METABOX_DSC_CHECK=1 flag to mitigate glitches
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_install-netcore-feature.ps1"
        ]
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
          ],
          "elevated_user" => "vagrant",
          "elevated_password" => "vagrant"
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
          "output": "#{working_dir}/packer_boxes/win2016-mb-app-#{git_branch}-{{.Provider}}.box"
        }
      }
      
    end

  end

end