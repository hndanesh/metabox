
module Metabox

    class TaskExecutionService < ServiceBase

        @task_services = nil

        def initialize
            
        end
        
        def name
            "metabox::core::task_execution_service"
        end

        def execute_task(task_name:, params:)
            log.info "Executing Task: [#{task_name}] with params: #{params}"

            task_parts = task_name.split(':')

            service_name = task_parts[0]
            task_name = task_parts[1]

            service = _services[service_name]
            
            if service.nil?
                raise "Cannot find service by name: #{service_name}"
            end

            service.send(task_name, params)
        end

        private 

        def _services
            if  @task_services == nil
                @task_services = _get_task_services
            end

            @task_services
        end

        def _get_task_services
            result = {}
      
            services = Metabox::ServiceContainer.instance.get_services(Metabox::TaskServiceBase)
      
            services.each do | service |
              log.verbose "Regestering task service: #{service.name} -> #{service.rake_alias}"
              result[service.rake_alias] = service
            end
         
            result
          end

    end

end