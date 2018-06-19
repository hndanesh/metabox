MetaboxResource.define_config("win2016-mb-bin-sp16rtm") do | metabox |

  git_branch   = metabox.env.get_metabox_branch
  working_dir  = metabox.env.get_metabox_working_dir
  download_dir = metabox.env.get_metabox_downloads_path

  custom_machine_folder = "#{working_dir}/vagrant_vms/metabox_canary_win2016"

  box_name             = "win2016-mb-app-#{git_branch}"
  sp16rtm_box_name     = "win2016-mb-bin-sp16rtm-#{git_branch}"

  skip_windows_updates = true
  
  sp_install_dir       = "C:\\_metabox_resources\\sp2016_rtm"
  
  # SP2016 product key
  sp_product_key       = metabox.env.METABOX_SP16_PRODUCT_KEY

  if sp_product_key.nil? 
    sp_product_key = "NQGJR-63HC8-XCRQH-MYVCH-3J3QR"
  end 

  metabox.description = "Builds Windows 2016 + SharePoint 2016 RTM binary image"

  metabox.define_packer_build("win2016-mb-bin-sp16rtm") do | packer_build |

    packer_build.packer_file_name = "win2016-mb-bin-sp16rtm.json"
    packer_build.vagrant_box_name = sp16rtm_box_name

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
            "output_directory" => "#{working_dir}/packer_output/win2016-mb-bin-sp16rtm-#{git_branch}",
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

      # transfer binaries
      # - sp2013server_rtm
      # - sp2013_prerequisites
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_metabox_dist_helper.ps1"
        ],
        "environment_vars" => [
          "METABOX_RESOURCE_NAME=sp2016_rtm"
        ]
      }

      # SP2016 prerequisites: install, reboot, install
      # by this time, 'app' image shoudl already have windows features and NET35 installed
      # we should be ok with 3 hits and reboots to get pre-req installed
      2.times do | index |

        env_vars = [
            "METABOX_INSTALL_DIR=#{sp_install_dir}"
        ]

        if index == 1 
          env_vars <<  "METABOX_DSC_CHECK=1"
        end

        packer_template.provisioners << { 
          "type" => "powershell",
          "scripts" => [
            "./scripts/packer/metabox.packer.core/_sp2013_pre_rtm.ps1"
          ],
          "environment_vars" => env_vars
        }

        if index != 1 
          packer_template.provisioners << { 
            "type" => "windows-restart"
          }
        end
      end

      # SP2016 bin install: install, reboot, install
      # two hits to install binaries, one reboot in between
      2.times do | index |

        env_vars = [
          "METABOX_INSTALL_DIR=#{sp_install_dir}",
          "METABOX_SP_PRODUCT_KEY=#{sp_product_key}"
        ]

        if index == 1 
          env_vars <<  "METABOX_DSC_CHECK=1"
        end

        packer_template.provisioners << { 
          "type" => "powershell",
          "scripts" => [
            "./scripts/packer/metabox.packer.core/_sp2013_bin.ps1"
          ],
          "environment_vars" => env_vars
        }

        if index != 1
          packer_template.provisioners << { 
            "type" => "windows-restart"
          }
        end
      end 

      # finalizing image
      # cleaning up install folder, smaller image
      packer_template.provisioners << { 
        "type" => "powershell",
        "inline" => [
          "Remove-Item '#{sp_install_dir}}\\*' -Recurse -Force -ErrorAction SilentlyContinue"
        ]
      }
      packer_template.provisioners << { 
        "type" => "windows-restart"
      }

      packer_template.post_processors << {
        "Type" => "packer::post-processors::vagrant",
        "Properties" => {
          "output": "#{working_dir}/packer_boxes/win2016-mb-bin-sp16rtm-#{git_branch}-{{.Provider}}.box"
        }
      }
      
    end

  end

  # builds SharePoint 2016 Feature Pack 2 image
  # - uses win2016-mb-bin-sp16rtm image as a base 
  # - patches up KB4011127 from file resources
  metabox.define_packer_build("win2016-mb-bin-sp16fp2") do | packer_build |

    packer_build.packer_file_name = "win2016-mb-bin-sp16fp2.json"
    packer_build.vagrant_box_name = "win2016-mb-bin-sp16fp2-#{git_branch}"

    packer_build.define_packer_template do | packer_template |

      packer_template.builders << {
        "Type" => "packer::builders::vagrant_win16_sysprep",
        "Properties" => {
          "box_name" => sp16rtm_box_name,
          "builder" => {
            "guest_additions_mode" => "attach",
            "communicator" => "winrm",
            "winrm_username" => "vagrant",
            "winrm_password" => "vagrant",
            "winrm_timeout" => "12h",
            "output_directory" => "#{working_dir}/packer_output/win2016-mb-bin-sp16fp2-#{git_branch}",
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

      # transfer binaries
      # - sp2016_fp2
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_metabox_dist_helper.ps1"
        ],
        "environment_vars" => [
          "METABOX_RESOURCE_NAME=sp2016_fp2"
        ]
      }

      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_metabox_install_package.ps1"
        ],
        "environment_vars" => [
          "METABOX_APP_PACKAGE_NAME=KB4011127",
          "METABOX_APP_PACKAGE_FILE_PATH=C:\\_metabox_resources\\sp2016_fp2\\sts2016-kb4011127-fullfile-x64-glb.exe",
          "METABOX_APP_PACKAGE_FILE_TYPE=exe",
          "METABOX_APP_PACKAGE_SILENT_ARGS=/quiet /norestart",
          "METABOX_APP_PACKAGE_EXIT_CODES=0,3010"
        ],
        "valid_exit_codes" => [ 0, 3010 ]
      }

      # finalizing image
      # cleaning up install folder, smaller image
      packer_template.provisioners << { 
        "type" => "powershell",
        "inline" => [
          "Remove-Item '#{sp_install_dir}\\*' -Recurse -Force -ErrorAction SilentlyContinue"
        ]
      }
      packer_template.provisioners << { 
        "type" => "windows-restart"
      }

      packer_template.post_processors << {
        "Type" => "packer::post-processors::vagrant",
        "Properties" => {
          "output": "#{working_dir}/packer_boxes/win2016-mb-bin-sp16fp2-#{git_branch}-{{.Provider}}.box"
        }
      }

    end

  end

end