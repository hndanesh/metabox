
MetaboxResource.define_config("metabox-sharepoint2016") do | metabox |

  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads SharePoint 2016"

  metabox.define_file_set("sp2016") do | file_set |

    file_set.define_file("sp2016server_rtm") do | file |
      file.source_url        = "http://care.dlservice.microsoft.com/dl/download/0/0/4/004EE264-7043-45BF-99E3-3F74ECAE13E5/officeserver.img"
      file.destination_path  = "#{download_dir}/sp2016_rtm/officeserver.img"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "9928405ae16a6f3d5b46c5772c7492e6dd2a26c4"
      end  
    end

    file_set.define_file("sp2016_fp2") do | file |
      file.source_url        = "https://download.microsoft.com/download/1/D/4/1D47CBEE-9B6E-467D-9090-E99CC3B5954F/sts2016-kb4011127-fullfile-x64-glb.exe"
      file.destination_path  = "#{download_dir}/sp2016_fp2/sts2016-kb4011127-fullfile-x64-glb.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "8999e93063fd45b9674ba9dcc884659fde90487d"
      end  
    end

  end

end