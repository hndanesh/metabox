require_relative 'resource_base' 
include Metabox::Resources

module Metabox
    module Resources  

        class PackerTemplateResource < ResourceBase
            
            attr_accessor :builders
            attr_accessor :provisioners
            attr_accessor :post_processors

            def _init_dsl_properties
                @builders = []
                @provisioners = []
                @post_processors = []
            end
        end

        class PackerBuildResource < ResourceBase
        
            attr_accessor :os

            attr_accessor :packer_file_name
            attr_accessor :vagrant_box_name
            attr_accessor :packer_template

            attr_accessor :require_tools
        
            def _init_dsl_properties
                @require_tools = []
            end

            def dsl_properties
                [
                    "packer_file_name",
                    "vagrant_box_name"
                ]
            end

            def define_packer_template(name = "default", &block)

                if !block_given?
                    return  @packer_template
                end

                @packer_template = PackerTemplateResource.new(name, &block)
                @packer_template
            end
    
        end

    end
end