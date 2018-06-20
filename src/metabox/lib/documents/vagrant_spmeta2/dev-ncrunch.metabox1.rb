MetaboxResource.define_config("dev-ncrunch") do | metabox |

  ncrunch_version = "3.2.3"

  metabox.description = "Installs NCrunch on vs13/vs15 VMs"

  metabox.define_revision("ncrunch-2013") do | revision |
    revision.target_resource = [
      {
        "match_type" => "tag",
        "values"     => [ "vs13" ]
      }
    ]

    revision..add_configs([
      {
        "Type" => "metabox::vagrant::shell",
        "Tags" => [ "revision", "ncrunch-2013" ],
        "Name" => "ncrunch-2013",
        "Properties" => {
          "path" => "./scripts/ncrunch/ncrunch_plugin.ps1",
          "env"  => [
            "NCRUNCH_PLUGIN_NAME=ncrunch-vs2013",
            "NCRUNCH_PLUGIN_VERSION=#{ncrunch_version}"
          ]
        }
      }
    ]
  end

  metabox.define_revision("ncrunch-2015") do | revision |
    revision.target_resource = [
      {
        "match_type" => "tag",
        "values"     => [ "vs15" ]
      }
    ]

    revision..add_configs([
      {
        "Type" => "metabox::vagrant::shell",
        "Tags" => [ "revision", "ncrunch-2015" ],
        "Name" => "ncrunch-2013",
        "Properties" => {
          "path" => "./scripts/ncrunch/ncrunch_plugin.ps1",
          "env"  => [
            "NCRUNCH_PLUGIN_NAME=ncrunch-vs2015",
            "NCRUNCH_PLUGIN_VERSION=#{ncrunch_version}"
          ]
        }
      }
    ]
  end

  metabox.define_revision("ncrunch-grid-server") do | revision |
    revision.target_resource = [
      {
        "match_type" => "tag",
        "values"     => [ "vs13", "vs15", "sp", "sp13", "sp16" ]
      }
    ]

    revision..add_configs([
      {
        "Type" => "metabox::vagrant::shell",
        "Tags" => [ "revision", "ncrunch-gridnodeserver" ],
        "Name" => "ncrunch-gridnodeserver",
        "Properties" => {
          "path" => "./scripts/ncrunch/ncrunch_gridnode_server.ps1",
          "env"  => [
            "NCRUNCH_GRIDNODE_VERSION=#{ncrunch_version}",
            "NCRUNCH_GRIDNODE_USER_NAME=#{revision.stack.dc_short_name}\\vagrant",
            "NCRUNCH_GRIDNODE_USER_PASSWORD=vagrant"
          ]
        }
      }
    ]
  end

end