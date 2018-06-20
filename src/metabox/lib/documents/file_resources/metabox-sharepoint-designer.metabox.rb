
MetaboxResource.define_config("metabox-sharepoint-designer") do | metabox |

  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads SharePoint Designer"

  metabox.define_file_set("spd2013") do | file_set |

    file_set.define_file("spd_x32") do | file |
      file.source_url        = "https://download.microsoft.com/download/3/E/3/3E383BC4-C6EC-4DEA-A86A-C0E99F0F3BD9/sharepointdesigner_32bit.exe"
      file.destination_path  = "#{download_dir}/spd2013_x32/sharepointdesigner_32bit.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "7be30cadc49d66f116ab4aa303bbfed937846825"
      end  
    end

    file_set.define_file("spd_x64") do | file |
      file.source_url        = "https://download.microsoft.com/download/3/E/3/3E383BC4-C6EC-4DEA-A86A-C0E99F0F3BD9/sharepointdesigner_64bit.exe"
      file.destination_path  = "#{download_dir}/spd2013_x64/sharepointdesigner_64bit.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "60041617c421962c28e71f712e299e29f51651fb"
      end  
    end

  end

end