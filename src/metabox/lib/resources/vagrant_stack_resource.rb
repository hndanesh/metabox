require_relative 'resource_base' 
include Metabox::Resources

module Metabox
    module Resources  

        class VagrantHostResource < ResourceBase
         
            attr_accessor :os 

            attr_accessor :host_name
            attr_accessor :handlers
            attr_accessor :require_tools
          
            attr_accessor :depends_on  

            # def dsl_properties
            #     [
            #         "host_name",
            #         "handlers"
            #     ]
            # end

            def stack 
                @parent
            end

            def get_host_name

                if stack.nil?
                    error_message = "Cannot find parent stack for resource: #{self.inspect}"
                    
                    log.error error_message
                    raise error_message
                end

                service = get_service_by_name("metabox::vagrant::config::base")
                service.get_host_name(environment_name: stack.name, vm_name: name)
            end

            def _init_dsl_properties
               @os = "windows"

               @handlers = []
               @require_tools = []

               @stack = nil
               @depends_on = []
            end

            def configs 
                @handlers
            end

            def add_role(role)
                log.debug "  - adding role: #{role.name}"

                log.debug "     - validating role #{role.name}"
                role.validate(vagrant_host: self)

                log.debug "     - configuring role: #{role.name}"
                role.configure(vagrant_host: self)
            end

            def add_roles(roles)
                roles.each do | role |
                    add_role(role)
                end
            end

            def add_config(config) 
                @handlers << config
            end

            def add_configs(configs) 
                configs.each do | config |
                    add_config(config)
                end
            end
        end

        class VagrantStackResource < ResourceBase
        
            attr_accessor :dc_domain_full_name

            def dc_short_name
                @dc_domain_full_name.split('.').first 
            end

            def define_host(host_name, &block)
                define_vagrant_host(host_name, &block)
            end

            def define_vagrant_host(host_name, &block)

                vagrant_host = VagrantHostResource.new(host_name, self, &block)
             
                @resources << vagrant_host
                @resources.last
            end
    
        end

    end
end