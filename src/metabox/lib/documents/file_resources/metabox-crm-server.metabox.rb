
MetaboxResource.define_config("metabox-crm-server") do | metabox |

  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads CRM Server 2016"

  metabox.define_file_set("crm") do | file_set |

    file_set.define_file("crm2016-80") do | file |
      file.source_url        = "https://download.microsoft.com/download/3/4/F/34FB8C80-F245-41E7-AFE2-6388005A702B/CRM2016-Server-ENU-amd64.exe"
      file.destination_path  = "#{download_dir}/crm2016/CRM2016-Server-ENU-amd64.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "192882bccbc976b58f4259b4f9498edb1b23c526"
      end  
    end

  end

end