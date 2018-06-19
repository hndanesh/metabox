
MetaboxResource.define_config("metabox-jetbrains") do | metabox |

  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads jetbrains tooling"

  metabox.define_file_set("jetbrains") do | file_set |

    file_set.define_file("ReSharperUltimate.2018.1.2") do | file |
      file.source_url        = "https://download-cf.jetbrains.com/resharper/JetBrains.ReSharperUltimate.2018.1.2.exe"
      file.destination_path  = "#{download_dir}/JetBrains/JetBrains.ReSharperUltimate.2018.1.2.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "3e80a02cf95cb6ed8a9325bde633c26232e71016"
      end  
    end

  end

end