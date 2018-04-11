
require_relative 'role_base'

include Metabox::Roles

module Metabox
    module Roles

        class MinimalHostRole < RoleBase

            attr_accessor :box_name 
          
            attr_accessor :cpus 
            attr_accessor :memory 
            attr_accessor :machinefolder 
          
            def self.default(box_name, &block)
              result = MinimalHostRole.new(&block)
          
              result.box_name = box_name
          
              result
            end
          
            def self.half_g(box_name, &block)
              result = self.default(box_name, &block)
          
              result.cpus = 2
              result.memory = 1024 * 0.5
          
              result
            end

            def self.one_g(box_name, &block)
              result = self.default(box_name, &block)
          
              result.cpus = 2
              result.memory = 1024 * 1
          
              result
            end
          
            def self.four_g(box_name, &block)
              result = self.default(box_name, &block)
          
              result.cpus = 4
              result.memory = 1024 * 4
          
              result
            end

            def self.six_g(box_name, &block)
                result = self.default(box_name, &block)
            
                result.cpus = 4
                result.memory = 1024 * 6
            
                result
            end
          
            def self.eight_g(box_name, &block)
              result = self.default(box_name, &block)
          
              result.cpus = 4
              result.memory = 1024 * 8
          
              result
            end
          
            def self.twelve_g(box_name, &block)
              result = self.default(box_name, &block)
          
              result.cpus = 4
              result.memory = 1024 * 12
          
              result
            end
          
          
            def name 
              "metabox-dc12"
            end
          
            def _init_properties
              super

              @cpus = 2
              @memory = 512
              @machinefolder = nil
            end
          
            def validate(vagrant_host:)
              if box_name.nil? 
                raise "box_name is nil"
              end
            end
          
            def configure(vagrant_host:)
              
              virtualbox_props = {
                "cpus"   => @cpus,
                "memory" => @memory.to_i
              }
          
              if !@machinefolder.nil?
                virtualbox_props["machinefolder"] = @machinefolder
              end
              
              vagrant_host.add_configs([
                {
                  "Type" => "vagrant::config::vm",
                  "Properties" => {
                    "box" => @box_name
                  }
                },
                
                {
                  "Type" => "vagrant::config::vm::provider::virtualbox",
                  "Properties" => virtualbox_props
                },  
          
                {
                  "Type" => "metabox::vagrant::host",
                  "Properties" => {
                    "hostname" => vagrant_host.get_host_name
                  }
                }  
              ])
            end
          
          end
          

    end

end