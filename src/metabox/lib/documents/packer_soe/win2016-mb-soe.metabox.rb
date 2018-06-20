
MetaboxResource.define_config("win2016-mb-soe") do | metabox |

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir
  custom_machine_folder = "#{working_dir}/vagrant_vms/metabox_canary_win2016"

  skip_windows_updates = !metabox.env.SOE_SKIP_WIN_UPDATE.nil?

  metabox.description = "Builds Windows 2016 SOE image"

  metabox.define_packer_build("win2016-mb-soe") do | packer_build |

    packer_build.packer_file_name = "win2016-mb-soe.json"
    packer_build.vagrant_box_name = "win2016-mb-soe-#{git_branch}"

    iso_url      = "http://care.dlservice.microsoft.com/dl/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO"
    iso_checksum = "18a4f00a675b0338f3c7c93c4f131beb"
   
    packer_build.define_packer_template do | packer_template |
     
      packer_template.builders << {
        "Type" => "packer::builders::packer_win16_sysprep",
        "Properties" => {
          "output_directory" => "#{working_dir}/packer_output/win2016-mb-soe-#{git_branch}",
              
          "iso_url" => iso_url,
          "iso_checksum" =>  iso_checksum,
          "iso_checksum_type" =>  "md5"
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

      # pre-install virtual box additions
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_install-virtualboxadditions.ps1"
        ],
        "only" => [
          "virtualbox-iso"
        ]
      }

      # installing all required features, rebooting
      # mostly, uninstalling Defender feature
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/win2016/_install-features-win16.ps1"
        ]
      }
      packer_template.provisioners << { 
        "type" => "windows-restart"
      }

      # bootstrapping chocolatey
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_choco_bootstrap.ps1"
        ]
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
            "Write-Host 'Downloading windows10.0-kb4103720-x64_c1fb7676d38fffae5c28b9216220c1f033ce26ac.msu...'",
            "Invoke-RestMethod -Uri http://download.windowsupdate.com/d/msdownload/update/software/updt/2018/05/windows10.0-kb4103720-x64_c1fb7676d38fffae5c28b9216220c1f033ce26ac.msu -OutFile \"$env:Temp/windows10.0-kb4103720-x64_c1fb7676d38fffae5c28b9216220c1f033ce26ac.msu\"",
            "Write-Host 'Running windows10.0-kb4103720-x64_c1fb7676d38fffae5c28b9216220c1f033ce26ac.msu...'",
            "Start-Process 'wusa.exe' -ArgumentList @( \"$env:Temp/windows10.0-kb4103720-x64_c1fb7676d38fffae5c28b9216220c1f033ce26ac.msu\", '/quiet', '/norestart' ) -Wait -NoNewWindow",
            "Remove-Item $env:Temp/windows10.0-kb4103720-x64_c1fb7676d38fffae5c28b9216220c1f033ce26ac.msu",
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
          "output": "#{working_dir}/packer_boxes/win2016-mb-soe-#{git_branch}-{{.Provider}}.box"
        }
      }
      
    end

  end

end