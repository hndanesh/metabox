
MetaboxResource.define_config("centos7-jenkins2") do | metabox |

  metabox.description = " Builds Vagrant VMs to trigger Vagrant box downloads. Later, these boxes are used with packer-vagrant builder to build other SOEs"

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir

  # these boxes are used by windows 2012/2012-r2 metabox SOEs
  box_win2012     = "opentable/win-2012-standard-amd64-nocm"
  box_win2012_r2  = "opentable/win-2012r2-standard-amd64-nocm"
  # this box is used for metabox CI box to build up Jenkins2 with pipelines
  box_centos7     = "geerlingguy/centos7"
  # standart hashicorp's precise64 for testing purposes
  box_precise64   = "hashicorp/precise64"

  custom_machine_folder = "#{working_dir}/vagrant_vms/#{git_branch}/metabox_canary"

  def standard_config(vagrant_host:, box_name:, machinefolder:)
      vagrant_host.handlers << {
        "Type" => "vagrant::config::vm",
        "Properties" => {
          "box" => box_name
        }
      }

      vagrant_host.handlers << {
        "Type" => "vagrant::config::vm::provider::virtualbox",
        "Properties" => {
          "cpus" => 2,
          "memory" => 512,
          "machinefolder" => machinefolder
        }
      }
  end

  metabox.define_vagrant_stack("soe-canary") do | vagrant_stack |

    vagrant_stack.define_vagrant_host("win2012") do | vagrant_host |
      standard_config(
        vagrant_host: vagrant_host,
        box_name: box_win2012,
        machinefolder: custom_machine_folder
      )
    end

    vagrant_stack.define_vagrant_host("win2012-r2") do | vagrant_host |
      standard_config(
        vagrant_host: vagrant_host,
        box_name: box_win2012_r2,
        machinefolder: custom_machine_folder
      )
    end

    vagrant_stack.define_vagrant_host("centos7") do | vagrant_host |

      vagrant_host.os = "linux"

      standard_config(
        vagrant_host: vagrant_host,
        box_name: box_centos7,
        machinefolder: custom_machine_folder
      )
    
    end

    vagrant_stack.define_vagrant_host("precise64") do | vagrant_host |
    
      vagrant_host.os = "linux"

      standard_config(
        vagrant_host: vagrant_host,
        box_name: box_precise64,
        machinefolder: custom_machine_folder
      )

    end

  end

end