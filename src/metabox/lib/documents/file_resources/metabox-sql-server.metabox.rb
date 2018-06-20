
MetaboxResource.define_config("metabox-sharepoint2016") do | metabox |

  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads SQL Server 2012, 2014, 2016"

  metabox.define_file_set("sql") do | file_set |

    file_set.define_file("sql2012sp2") do | file |
      file.source_url        = "https://download.microsoft.com/download/4/C/7/4C7D40B9-BCF8-4F8A-9E76-06E9B92FE5AE/ENU/SQLFULL_ENU.iso"
      file.destination_path  = "#{download_dir}/sql2012sp2/SQLFULL_ENU.iso"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "be00942cc56d033e2c9dce8a17a6f2654f5184a3"
      end  
    end

    file_set.define_file("sql2014sp1") do | file |
      file.source_url        = "http://care.dlservice.microsoft.com/dl/download/2/F/8/2F8F7165-BB21-4D1E-B5D8-3BD3CE73C77D/SQLServer2014SP1-FullSlipstream-x64-ENU.iso"
      file.destination_path  = "#{download_dir}/sql2014sp1/SQLServer2014SP1-FullSlipstream-x64-ENU.iso"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "d5fd3dabd8a66a7ea661d7fb1af444bfaacb22e3"
      end  
    end

    file_set.define_file("sql2016_rtm") do | file |
      file.source_url        = "http://care.dlservice.microsoft.com/dl/download/F/E/9/FE9397FA-BFAB-4ADD-8B97-91234BC774B2/SQLServer2016-x64-ENU.iso"
      file.destination_path  = "#{download_dir}/sql2016/SQLServer2016-x64-ENU.iso"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "ce21bf1c08ec1ac48ebb4988a8602c7813034ea3"
      end  
    end

    file_set.define_file("sql-ssms17.04:") do | file |
      file.source_url        = "https://go.microsoft.com/fwlink/?linkid=864329"
      file.destination_path  = "#{download_dir}/sql-ssms17.04/ssms-setup-enu.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "fb48d148724ca62b330fc23ea31d080ef5607608"
      end  
    end

  end

end