
MetaboxResource.define_config("metabox-7zip") do | metabox |

  git_branch  = metabox.env.get_metabox_branch
  working_dir = metabox.env.get_metabox_working_dir
  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads 7zip software"

  metabox.define_file_set("7zip") do | file_set |

    file_set.define_file("7zip-17.01-x86") do | file |
      file.source_url        = "http://www.7-zip.org/a/7z1701.exe"
      file.destination_path  = "#{download_dir}/7z1701-x86/7z1701-x86.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "2c94bd39e7b3456873494c1520c01ae559bc21d7"
      end  
    end

    file_set.define_file("7zip-17.01-x64") do | file |
      file.source_url        = "http://www.7-zip.org/a/7z1701-x64.exe"
      file.destination_path  = "#{download_dir}/7z1701-x64/7z1701-x64.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "9f3d47dfdce19d4709348aaef125e01db5b1fd99"
      end  
    end

  end

end