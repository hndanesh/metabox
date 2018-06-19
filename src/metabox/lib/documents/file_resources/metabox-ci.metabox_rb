
MetaboxResource.define_config("metabox-ci-downloads") do | metabox |

  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads java8 software"

  metabox.define_file_set("metabox-ci") do | file_set |

    file_set.define_file("jdk-8u141-linux-x64") do | file |
      file.source_url        = "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz"
      file.destination_path  = "#{download_dir}/jdk-8u141-linux-x64/jdk-8u144-linux-x64.tar.gz"

      file.options = [
        "--no-check-certificate",
        "--no-cookies" ,
        '--header "Cookie: oraclelicense=accept-securebackup-cookie"'
      ]

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "d6eb6e5b263b946b0793dd3c8dd6c294f28974c5"
      end  
    end

  end

end