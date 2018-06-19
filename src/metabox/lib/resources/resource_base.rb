module Metabox
    module Resources  

        class ResourceBase

            attr_accessor :name
            attr_accessor :description
            attr_accessor :parent

            @resources;

            def initialize(name, parent = nil, &block)
        
                @parent = parent

                @name = name
                @resources = []

                @this = self.class
                class_name = @this.name
               
                _init_dsl_properties
        
                if block_given?
                    (block.arity < 1 ? (instance_eval &block) : block.call(self)) 
                end 
            end
        
            def services 
                Metabox::ServiceContainer.instance
            end

            def get_service_by_name(service_name)
                services.get_service_by_name(service_name)
            end

            def log
                services.get_service(Metabox::LogService) 
            end

            def env 
                result = Metabox::ServiceContainer.instance.get_service(Metabox::ResourceEnvironmentService)
                
                result
            end

            def resources
                @resources
            end

            def _init_dsl_properties
        
            end
        
            def dsl_properties
                []
            end
        
            def to_s(prefix = '')
                
                result = []
                result << @this.name
        
                dsl_properties.each do |name|
                    value = instance_variable_get("@" + name)
                    value_to_s = value.to_s
        
                    if value.is_a?(ResourceBase) 
                        value_to_s = value.to_s(prefix)
                    end
        
                    result << "#{prefix} - #{name}: #{value_to_s}"
                end

                @resources.each do | resource |
                    result << resource.to_s(prefix)
                end
        
                result.join("\n")
            end
        
        end

    end

end