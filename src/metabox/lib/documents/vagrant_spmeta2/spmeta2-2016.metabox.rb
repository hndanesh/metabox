MetaboxResource.define_config("spmeta2-2016") do | metabox |

  metabox.description = " Regression to test win2016 platform - DC, client, SQL, VS and SharePoint"

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir

  custom_machine_folder = "#{working_dir}/vagrant_vms/#{git_branch}/spmeta2-win2016"
  
  box_app     =  "win2016-mb-app-#{git_branch}"
  box_sp      =  "win2016-mb-bin-sp16fp2-#{git_branch}"

  dc_domain_full_name  = "meta16.local"

  # defaults custom folders to custom_machine_folder if not provides via ENV variables
  # this allows VM placing on different drives
  machine_folder_dc    = metabox.env.METABOX_SPMETA_MACHINE_FOLDER_DC(custom_machine_folder)  + "/#{git_branch}"
  machine_folder_sql   = metabox.env.METABOX_SPMETA_MACHINE_FOLDER_SQL(custom_machine_folder) + "/#{git_branch}"
  machine_folder_dev   = metabox.env.METABOX_SPMETA_MACHINE_FOLDER_DEV(custom_machine_folder) + "/#{git_branch}"

  machine_ram          = metabox.env.METABOX_SPMETA_MACHINE_RAM(1024 * 6)
  machine_cpus         = metabox.env.METABOX_SPMETA_MACHINE_CPUS(4)

  # name of a standalone or sharedvm name
  # standalone: (sql + sp + vs) per VM
  # shared    : shared sql + (sp/vs per dev VM)
  dev_local_vm_name     =  metabox.env.SPMETA_DEV_LOCAL_VM_NAME
  dev_shared_vm_name    =  metabox.env.SPMETA_DEV_SHARED_VM_NAME

  metabox.define_vagrant_stack("spmeta2-2016") do | vagrant_stack |
  
    vagrant_stack.dc_domain_full_name = dc_domain_full_name

    dc_host = vagrant_stack.define_host("dc") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.one_g(box_app) do | role | 
          role.machinefolder = machine_folder_dc
        end,
        Win12SOERole.default,
        WinDCRole.default
      ])
    end

    sql14_host = vagrant_stack.define_host("sql14") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.four_g(box_app) do | role | 
          role.machinefolder = machine_folder_sql
        end,
        Win12SOERole.default,
        WinDCJoinRole.default,
        Sql14Role.default 
      ])
    end

    # standalone dev vm
    # - sql + sharepoint + vs2015
    vagrant_stack.define_host("dev-local-#{dev_local_vm_name}") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.default(box_sp) do | role | 
          role.memory  = machine_ram
          role.cpus    = machine_cpus

          role.machinefolder = machine_folder_dev
        end,
        Win12SOERole.default,
        WinDCJoinRole.default,

        Sql14Role.default,

        SharePoint16_Standalone_Role.default do | role |
          role.sp_farm_sql_server_host_name = vagrant_host.get_host_name
        end,

        VisualStudio15_SP3_Enterprise_Role.default 
      ])
    end

    # shared dev vm
    # - sql14_host is shared for every dev install 
    # - sharepoint + vs2015
    # - vs2015
    vagrant_stack.define_host("dev-shared-#{dev_shared_vm_name}") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host,
        sql14_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.default(box_sp) do | role | 
          role.memory  = machine_ram
          role.cpus    = machine_cpus

          role.machinefolder = machine_folder_dev
        end,
        Win12SOERole.default,
        WinDCJoinRole.default,

        SharePoint16_Standalone_Role.default do | role |
          role.sp_farm_sql_server_host_name = sql14_host.get_host_name
        end,

        VisualStudio15_SP3_Enterprise_Role.default 
      ])
    end
  
  end

end