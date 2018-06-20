MetaboxResource.define_config("win2012-r2-mb-bin-sp13") do | metabox |

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir
  download_dir = metabox.env.get_metabox_downloads_path

  custom_machine_folder = "#{working_dir}/vagrant_vms/metabox_canary_win2016"

  box_name             = "win2012-r2-mb-app-#{git_branch}"
  skip_windows_updates = !metabox.env.SOE_SKIP_WIN_UPDATE.nil?
  
  sp_install_dir       = "C:\\_metabox_resources\\sp2013sp1"
  
  # SP2013 product key
  sp_product_key       = metabox.env.METABOX_SP13_SP1_PRODUCT_KEY

  metabox.description = "Builds Windows 2012 R2 + SharePoint 2013 SP1 binary image"

  metabox.define_packer_build("win2012-r2-mb-bin-sp13") do | packer_build |

    packer_build.packer_file_name = "win2012-r2-mb-bin-sp13.json"
    packer_build.vagrant_box_name = "win2012-r2-mb-bin-sp13-#{git_branch}"

    packer_build.define_packer_template do | packer_template |
     
      packer_template.builders << {
        "Type" => "packer::builders::vagrant_win12_sysprep",
        "Properties" => {
          "box_name" => box_name,
          "builder" => {
            "output_directory" => "#{working_dir}/packer_output/win2012-mb-app-#{git_branch}",
            "http_directory" => download_dir
          }
        }
      }

      # vagrant_win12_sysprep support files
      packer_template.provisioners << { 
        "type" => "file",
        "source" => "./scripts/packer/metabox.packer.core/answer_files/2012/Autounattend_sysprep.xml",
        "destination" => "c:/Windows/Temp/Autounattend_sysprep.xml"
      }

      # transfer binaries
      # - sp2013sp1
      # - sp2013_prerequisites
      packer_template.provisioners << { 
        "type" => "powershell",
        "scripts" => [
          "./scripts/packer/metabox.packer.core/_metabox_dist_helper.ps1"
        ],
        "environment_vars" => [
          "METABOX_RESOURCE_NAME=sp2013sp1"
        ]
      }

      # SP2013 prerequisites: install, reboot, install
      # by this time, 'app' image shoudl already have windows features and NET35 installed
      # we should be ok with 3 hits and reboots to get pre-req installed
      3.times do | index |

        env_vars = [
            "METABOX_INSTALL_DIR=#{sp_install_dir}"
        ]

        if index == 2 
          env_vars <<  "METABOX_DSC_CHECK=1"
        end

        packer_template.provisioners << { 
          "type" => "powershell",
          "scripts" => [
            "./scripts/packer/metabox.packer.core/_sp2013_pre.ps1"
          ],
          "environment_vars" => env_vars
        }
        packer_template.provisioners << { 
          "type" => "windows-restart"
        }
      end

      # SP2013 bin install: install, reboot, install
      # two hits to install binaries, one reboot in between
      # SP2013 bin install: install, reboot, install
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
          "output": "#{working_dir}/packer_boxes/win2012-r2-mb-bin-sp13-#{git_branch}-{{.Provider}}.box"
        }
      }
      
    end

  end

end