
MetaboxResource.define_config("metabox-sharepoint2013") do | metabox |

  download_dir = metabox.env.get_metabox_downloads_path

  metabox.description = "Downloads SharePoint 2013"

  metabox.define_file_set("sp2013") do | file_set |

    file_set.define_file("sp2013foundation") do | file |
      file.source_url        = "https://download.microsoft.com/download/6/E/3/6E3A0B03-F782-4493-950B-B106A1854DE1/sharepoint.exe"
      file.destination_path  = "#{download_dir}/sp2013_foundation/sharepoint.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "a56ab44905f71556f37b8abe60eb23489e40e2e6"
      end  
    end

    file_set.define_file("sp2013server_rtm") do | file |
      file.source_url        = "http://care.dlservice.microsoft.com/dl/download/3/D/7/3D713F30-C316-49B8-9CC0-E1BFC34B63A0/SharePointServer_x64_en-us.img"
      file.destination_path  = "#{download_dir}/sp2013server_rtm/SharePointServer_x64_en-us.img"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "7c0af157cf2e0c2ec5288e4c52d91cea86816010"
      end  
    end

  end
      
  metabox.define_file_set("sp2013_prerequisites") do | file_set |

    file_set.define_file("dotnetfx45_full_x86_x64") do | file |
      file.source_url        = "http://download.microsoft.com/download/b/a/4/ba4a7e71-2906-4b2d-a0e1-80cf16844f5f/dotnetfx45_full_x86_x64.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/dotnetfx45_full_x86_x64.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "b2ff712ca0947040ca0b8e9bd7436a3c3524bb5d"
      end  
    end

    file_set.define_file("dotNetFx45_Full_setup") do | file |
      file.source_url        = "http://download.microsoft.com/download/B/A/4/BA4A7E71-2906-4B2D-A0E1-80CF16844F5F/dotNetFx45_Full_setup.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/dotNetFx45_Full_setup.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "f6ba6f03c65c3996a258f58324a917463b2d6ff4"
      end  
    end

    file_set.define_file("Windows6.1-KB2506143-x64") do | file |
      file.source_url        = "http://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/Windows6.1-KB2506143-x64.msu"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "31b738cc9a7ffb3addd3c575fc58dfa726be8a8a"
      end  
    end

    file_set.define_file("sqlncli") do | file |
      file.source_url        = "http://download.microsoft.com/download/9/1/3/9138773A-505D-43E2-AC08-9A77E1E0490B/1033/x64/sqlncli.msi"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/sqlncli.msi"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "6a694d7b751372e18f00b191147d005b0b580298"
      end  
    end

    file_set.define_file("sqlncli_amd64") do | file |
      file.source_url        = "http://download.microsoft.com/download/F/7/B/F7B7A246-6B35-40E9-8509-72D2F8D63B80/sqlncli_amd64.msi"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/sqlncli_amd64.msi"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "83ab8f54b56eb059d6848b1e0ce6efd5ea1ccbee"
      end  
    end

    file_set.define_file("Windows6.1-KB974405-x64") do | file |
      file.source_url        = "http://download.microsoft.com/download/D/7/2/D72FD747-69B6-40B7-875B-C2B40A6B2BDD/Windows6.1-KB974405-x64.msu"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/Windows6.1-KB974405-x64.msu"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "453cf16fec3a0a6674313660d783f323c6844858"
      end  
    end

    file_set.define_file("Synchronization") do | file |
      file.source_url        = "http://download.microsoft.com/download/E/0/0/E0060D8F-2354-4871-9596-DC78538799CC/Synchronization.msi"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/Synchronization.msi"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "211f16bd9254eaf6d0d838b944f25ad34a83da72"
      end  
    end

    file_set.define_file("WindowsServerAppFabricSetup_x64") do | file |
      file.source_url        = "http://download.microsoft.com/download/A/6/7/A678AB47-496B-4907-B3D4-0A2D280A13C0/WindowsServerAppFabricSetup_x64.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/WindowsServerAppFabricSetup_x64.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "6ebaa4c9100b1bc8ce4986a97be810b715783c09"
      end  
    end

    file_set.define_file("AppFabric1.1-KB2932678-x64-ENU") do | file |
      file.source_url        = "http://download.microsoft.com/download/E/D/9/ED9591F8-8720-4EE7-97D0-B6FD29C6D339/AppFabric1.1-KB2932678-x64-ENU.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/AppFabric1.1-KB2932678-x64-ENU.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "aa96ed85f750d91e92e16577169ca259822e3130"
      end  
    end

    file_set.define_file("MicrosoftIdentityExtensions") do | file |
      file.source_url        = "http://download.microsoft.com/download/0/1/D/01D06854-CA0C-46F1-ADBA-EBF86010DCC6/rtm/MicrosoftIdentityExtensions-64.msi"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/MicrosoftIdentityExtensions-64.msi"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "200f72f12a0272f10e04bfd2462dff11b5e81c4a"
      end  
    end

    file_set.define_file("setup_msipc_x64") do | file |
      file.source_url        = "http://download.microsoft.com/download/9/1/D/91DA8796-BE1D-46AF-8489-663AB7811517/setup_msipc_x64.msi"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/setup_msipc_x64.msi"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "e21612d85d81007d7b76d344b64bf68831ab234f"
      end  
    end

    file_set.define_file("WcfDataServices-5.0") do | file |
      file.source_url        = "http://download.microsoft.com/download/8/F/9/8F93DBBD-896B-4760-AC81-646F61363A6D/WcfDataServices.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/WcfDataServices-5.0.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "bdedf753fffb801304944ab9c49bcdadbf6ad137"
      end  
    end

    file_set.define_file("WcfDataServices-5.6") do | file |
      file.source_url        = "http://download.microsoft.com/download/1/C/A/1CAA41C7-88B9-42D6-9E11-3C655656DAB1/WcfDataServices.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/WcfDataServices-5.6.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "410548872df5168938a6253cd16696dca96ede94"
      end  
    end

    file_set.define_file("AppFabric1.1-RTM-KB2671763-x64-ENU") do | file |
      file.source_url        = "http://download.microsoft.com/download/7/B/5/7B51D8D1-20FD-4BF0-87C7-4714F5A1C313/AppFabric1.1-RTM-KB2671763-x64-ENU.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/AppFabric1.1-RTM-KB2671763-x64-ENU.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "d2a3c164a0539c75277726fba0ea190f4e024533"
      end  
    end

    file_set.define_file("447698_intl_x64_zip") do | file |
      file.source_url        = "http://hotfixv4.microsoft.com/Windows%207/Windows%20Server2008%20R2%20SP1/sp2/Fix402568/7600/free/447698_intl_x64_zip.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/447698_intl_x64_zip.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "324f8abfc7f3146731907167c3555ca42f7d0a5a"
      end  
    end

    file_set.define_file("433385_intl_x64_zip") do | file |
      file.source_url        = "http://hotfixv4.microsoft.com/Windows%207/Windows%20Server2008%20R2%20SP1/sp2/Fix368051/7600/free/433385_intl_x64_zip.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/433385_intl_x64_zip.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "ddf375dc976caaf1d95a5f23d36f7704847fcc51"
      end  
    end

    file_set.define_file("427087_intl_x64_zip") do | file |
      file.source_url        = "http://hotfixv4.microsoft.com/Windows%207/Windows%20Server2008%20R2%20SP1/sp2/Fix354400/7600/free/427087_intl_x64_zip.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/427087_intl_x64_zip.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "fc2e76908680ad2752b74feee564cb0f5c86a5ef"
      end  
    end

    file_set.define_file("Windows6.1-KB2567680-x64") do | file |
      file.source_url        = "http://download.microsoft.com/download/C/D/A/CDAF5DD8-3B9A-4F8D-A48F-BEFE53C5B249/Windows6.1-KB2567680-x64.msu"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/Windows6.1-KB2567680-x64.msu"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "9fb969409f32eb8988d5e68ea1b56d13dac75a1d"
      end  
    end

    file_set.define_file("NDP45-KB2759112-x64") do | file |
      file.source_url        = "http://download.microsoft.com/download/5/6/3/5631B753-A009-48AF-826C-2D2C29B94172/NDP45-KB2759112-x64.exe"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/NDP45-KB2759112-x64.exe"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "b45ae98ef267c136b62f86827854eb750d2ba318"
      end  
    end

    file_set.define_file("Windows8-RT-KB2765317-x64") do | file |
      file.source_url        = "http://download.microsoft.com/download/0/2/E/02E9E569-5462-48EB-AF57-8DCCF852E6F4/Windows8-RT-KB2765317-x64.msu"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/Windows8-RT-KB2765317-x64.msu"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "a7718c7e39903eeb63dc3667d143102692d13faa"
      end  
    end

    file_set.define_file("svrsetup_15-0-4709-1000_x64") do | file |
      file.source_url        = "https://download.microsoft.com/download/3/6/2/362C4A9C-4AFE-425E-825F-369D34D64F4E/svrsetup_15-0-4709-1000_x64.zip"
      file.destination_path  = "#{download_dir}/sp2013_prerequisites/svrsetup_15-0-4709-1000_x64.zip"

      file.define_checksum do | sum |
        sum.enabled = true
        sum.type    = "sha1"
        sum.value   = "05ce1354400bc6534e74347956ac0089393b859e"
      end  
    end

  end


  

end