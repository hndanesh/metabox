MetaboxResource.define_config("contoso-win2012-r2") do | metabox |

  metabox.description = "Regression to test win2012-r2 platform - DC, client, SQL, VS and SharePoint"

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir

  custom_machine_folder = "#{working_dir}/vagrant_vms/#{git_branch}/regression-win2012-r2"
  
  box_app     =  "win2012-r2-mb-app-#{git_branch}"
  box_sp      =  "win2012-r2-mb-bin-sp13-#{git_branch}"
  
  dc_domain_full_name  = "contoso12r2.local"

  metabox.define_vagrant_stack("contoso12r2") do | vagrant_stack |
  
    vagrant_stack.dc_domain_full_name = dc_domain_full_name

    dc_host = vagrant_stack.define_host("dc") do | vagrant_host |
      vagrant_host.add_roles([
        MinimalHostRole.one_g(box_app),
        Win12SOERole.default,
        WinDCRole.default
      ])
    end

    vagrant_stack.define_host("client") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.half_g(box_app),
        Win12SOERole.default,
        WinDCJoinRole.default 
      ])
    end

    vagrant_stack.define_host("vs13") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.four_g(box_app),
        Win12SOERole.default,
        WinDCJoinRole.default,

        VisualStudio13_SP5_Enterprise_Role.default 
      ])
    end

    vagrant_stack.define_host("vs15") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.four_g(box_app),
        Win12SOERole.default,
        WinDCJoinRole.default,

        VisualStudio15_SP3_Enterprise_Role.default
      ])
    end

    sql12 = vagrant_stack.define_host("sql12") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.four_g(box_app),
        Win12SOERole.default,
        WinDCJoinRole.default,
        Sql12Role.default 
      ])
    end

    sql14_host = vagrant_stack.define_host("sql14") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.four_g(box_app),
        Win12SOERole.default,
        WinDCJoinRole.default,
        Sql14Role.default 
      ])
    end

    sql16_host = vagrant_stack.define_host("sql16") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.four_g(box_app),
        Win12SOERole.default,
        WinDCJoinRole.default,
        Sql16Role.default 
      ])
    end

    vagrant_stack.define_host("sp13_sp1") do | vagrant_host |

      vagrant_host.depends_on = [
        dc_host,
        sql14_host
      ]

      vagrant_host.add_roles([
        MinimalHostRole.six_g(box_sp),
        Win12SOERole.default,
        WinDCJoinRole.default,

        SharePoint13_Standalone_Role.default do | role |
          role.sp_farm_sql_server_host_name = sql14_host.get_host_name
        end
      ])
    end
  
  end

end