
MetaboxResource.define_config("metabox-kb") do | metabox |

  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads Windows KBs"

  metabox.define_file_set("KB") do | file_set |

    file_set.define_file("KB2919355-2012r2") do | file |
      file.source_url        = "https://download.microsoft.com/download/2/5/6/256CCCFB-5341-4A8D-A277-8A81B21A1E35/Windows8.1-KB2919355-x64.msu"
      file.destination_path  = "#{download_dir}/KB2919355-2012r2/Windows8.1-KB2919355-x64.msu"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "e6f4da4d33564419065a7370865faacf9b40ff72"
      end  
    end

    file_set.define_file("KB2919442-2012r2") do | file |
      file.source_url        = "https://download.microsoft.com/download/D/6/0/D60ED3E0-93A5-4505-8F6A-8D0A5DA16C8A/Windows8.1-KB2919442-x64.msu"
      file.destination_path  = "#{download_dir}/KB2919442-2012r2/Windows8.1-KB2919442-x64.msu"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "f97d8290d9d75d96f163095c4cb05e1b9f6986e0"
      end  
    end

    file_set.define_file("KB3045557-2012r2") do | file |
      file.source_url        = "http://download.microsoft.com/download/C/3/A/C3A5200B-D33C-47E9-9D70-2F7C65DAAD94/NDP46-KB3045557-x86-x64-AllOS-ENU.exe"
      file.destination_path  = "#{download_dir}/KB3045557/NDP46-KB3045557-x86-x64-AllOS-ENU.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "3049a85843eaf65e89e2336d5fe6e85e416797be"
      end  
    end

  end

end