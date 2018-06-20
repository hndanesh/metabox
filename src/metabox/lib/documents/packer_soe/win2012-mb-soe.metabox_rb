
MetaboxResource.define_config("win2012-mb-soe") do | metabox |

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir
  custom_machine_folder = "#{working_dir}/vagrant_vms/metabox_canary_win2012"

  box_name             = "opentable/win-2012-standard-amd64-nocm"
  skip_windows_updates = !metabox.env.SOE_SKIP_WIN_UPDATE.nil?

  metabox.description = "Builds Windows 2012 SOE image"

  metabox.define_packer_build("win2012-mb-soe") do | packer_build |

    packer_build.packer_file_name = "win2012-mb-soe.json"
    packer_build.vagrant_box_name = "win2012-mb-soe-#{git_branch}"

    packer_build.define_packer_template do | packer_template |
     
      packer_template.builders << {
        "Type" => "packer::builders::vagrant_win12_shutdown",
        "Properties" => {
          "box_name" => box_name,
              
          "builder" => {
            output_directory: "#{working_dir}/packer_output/win2012-mb-soe-#{git_branch}"
          }
        }
      }

      # bootstrapping chocolatey, it need to have a reboot on 2012
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_choco_bootstrap.ps1"
        ]
      }
      packer_template.provisioners << { 
        "type" => "windows-restart"
      }
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_choco_packages.ps1",
          "./scripts/packer/metabox.packer.core/_setup-ps-nuget.ps1",
          "./scripts/packer/metabox.packer.core/_install-dsc-modules.ps1"
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
          "output": "#{working_dir}/packer_boxes/win2012-mb-soe-#{git_branch}-{{.Provider}}.box"
        }
      }
      
    end

  end

end