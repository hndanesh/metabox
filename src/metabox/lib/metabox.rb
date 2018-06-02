require 'objspace'
require 'yaml'
require 'json'
require "pp"

require_relative "metabox/version"

METABOX_ROOT = "#{File.dirname(__FILE__)}"

def _include_files(files, is_debug = false) 
  files.each do | file |
    
    file_path = "#{File.dirname(__FILE__)}/#{file}"

    if is_debug
      puts "  - including service file: #{file_path}"
    end

    require file_path
  end
end

def _include_folder_services(folders, is_debug = false) 
  folders.each do | folder |
    # include all 'common' halpers
    Dir.glob("#{File.dirname(__FILE__)}/#{folder}/**/*.rb").each { |file|
      
      if is_debug
        puts "  - including service file: #{file}"
      end

      require file
    }
  end
end

_include_folder_services [ "common", "utils" ]

_include_files [ 
  "services/service_container.rb",
  "services/service_base.rb"
]

_include_folder_services [  "documents", "services", "resources", "roles" ]

module Metabox
  
  def self.configure(&block)

      block.call($mb_api)
    
  end

  class ApiClient < ServiceBase
    
    @os_service = nil
    @task_service = nil

    def initialize

      handle_version_call

      super

      _init_services

      log.info "Initialized Metabox API client, version: #{Metabox::VERSION}"
    end

    def handle_version_call
      if ARGV.first == "metabox:version"
        # suspress all logging for version task
        # that produces clean output with version number
        log.disable
      end
    end

    def welcome_message
        log.debug "  - environment variables:"
        
        env_vars = env_service.get_metabox_variables(raise_on_missing_vars: false)
        env_vars.each { | name, value |
          tmp_value = value

          if name.downcase.include?("key") || name.downcase.include?("password")
            tmp_value = "****************"
          end

          log.debug "#{name}=#{tmp_value}"
        }

        log.debug " - cli arguments:"
        
        ARGV.each do |a|
          log.debug "#{a}"
        end
    
        is_windows = @os_service.is_windows?

        if is_windows 
          log.info "Delected windows platform: #{ENV['OS']}"
        else
          log.info "Delected non-windows platform: #{ENV['OS']}"
        end
    end

    def execute_task(task_name:, params:)
      @task_service.execute_task(task_name: task_name, params: params)
    end

    def configure_vagrant(config:)
      begin
        vagrant_config_service = get_service_by_name("metabox::vagrant::config::base")
        vagrant_config_service.configure_vagrant_config(config: config)
      rescue => exception 
        log.error "Error while configuring Metabox"
        log.error "#{exception}"

        raise exception
      end
    end

    private 

    def _container
      Metabox::ServiceContainer.instance
    end

    def _get_document_service
      _container.get_service_by_name("metabox::tasks:document")
    end 

    def _init_services
      @os_service   = _container.get_service_by_name("os")
      @task_service = _container.get_service_by_name("metabox::core::task_execution_service")
    end

  end

end
