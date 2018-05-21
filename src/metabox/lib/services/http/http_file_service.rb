
require 'open3'
require 'digest'

module Metabox

    class HttpFileService < ServiceBase

        def initialize
           
        end

        def name
            "metabox::http::file"
        end

        def execute_resource(resource_name, force = false)

            resource = document_service.get_download_files_resource_by_name(resource_name)

            _execute_pre_handlers(resource_name, resource)
            _execute_download(resource_name, resource, force)
            _execute_post_handlers(resource_name, resource)
        end

        def pack_resource(resource_name, force = false)
            resource = document_service.get_download_files_resource_by_name(resource_name)
            _process_resource_zip_folder_for_resource(resource_name, resource, force)
        end

        def import_resource(resource_name, path, force = false)
            resource = document_service.get_download_files_resource_by_name(resource_name)

            _execute_pre_handlers(resource_name, resource)
            _execute_download(resource_name, resource, force, path)
            _execute_post_handlers(resource_name, resource)
        end

        private

        def _get_download_tool_cmd
            env_service.get_metabox_download_tool_cmd
        end

        def _execute_pre_handlers(resource_name, resource)
            log.debug "Executing pre-handlers on resource: #{resource_name}"
            resource_value = resource.values.first

            scripts = [] 
            
            if resource_value.hooks && 
                resource_value.hooks["pre"] &&
                resource_value.hooks["pre"]["inline"] 
                scripts = resource_value.hooks["pre"]["inline"] 
            end

            home_folder = _get_destination_folder_path(resource_value)

            execute_inline_scripts(home_folder, scripts)
        end

        def _execute_post_handlers(resource_name, resource)
            log.info "Executing post-handlers on resource: #{resource_name}"
            resource_value = resource.values.first

            scripts = [] 
            
            puts resource_value

            if resource_value.hooks && 
                resource_value.hooks["post"] &&
                resource_value.hooks["post"]["inline"] 

                scripts = resource_value.hooks["post"]["inline"] 

                log.info "Found post-handler scripts"
            else 
                log.info "Cannot find post-handler script"
            end

            home_folder = _get_destination_folder_path(resource_value)

            execute_inline_scripts(home_folder, scripts)
        end

        def _execute_download(resource_name, resource, force = false, custom_path = nil)
            log.debug "Executing download on resource: #{resource_name}"

            home_folder = _get_destination_folder_path(resource.values.first)
            resource_value = resource.values.first

            src = resource_value.source_url

            if !custom_path.nil?
                custom_path = File.expand_path custom_path
                log.debug "Using custom_path to download file: #{custom_path}"

                if !File.exists? custom_path
                    raise "File does not exist: #{custom_path}"
                end

                src = custom_path
            end

            dst = resource_value.destination_path
            options =resource_value.options

            should_download = _process_checksum(resource_name, resource, dst)

            if force 
                log.debug "force: #{force}"
                should_download = force
            end

            should_pack = resource_value.is_file_resource

            if should_download 
                
                # clean up
                _delete_file dst

                # download
                _download_file(
                    src: src,
                    dst: dst,
                    options: options
                )

                file_sha1_value = _get_file_sha1_value(dst)
                log.warn "SHA1: #{file_sha1_value} for file: #{dst}"
            end

            if should_pack 
                _process_resource_zip_folder_for_resource(resource_name, resource, force)
            end            
        end

        def _download_and_pack

        end

        def _process_resource_zip_folder_for_resource(resource_name, resource, force = false)
            log.debug "Executing pack on resource: #{resource_name}"

            resource_value = resource.values.first

            dst = resource_value.destination_path
            _process_resource_zip_folder(file_path: dst, force: force)
        end

        def _process_checksum(resource_name, resource, file_path)
            result = true

            if !File.exists? file_path
                log.debug "File does not exist: #{file_path}"
                return true
            end

            resource_value =  resource.values.first           
            
            checksum_section = resource_value.checksum

            checksum_enabled = false
            checksum_type    = "sha1"
            checksum_value   = nil

            if !checksum_section.nil?
                checksum_enabled = checksum_section.enabled
                checksum_type = checksum_section.type
                checksum_value = checksum_section.value
            end

            if checksum_enabled.to_s.downcase != "true" 
                return true
            end

            if checksum_type.downcase != "sha1"
                log.error "sha1 is the only supported checksum. Giving type was: #{checksum_type}"
            end

            file_sha1_value = _get_file_sha1_value(file_path)
            log.warn "SHA1: #{file_sha1_value} for file: #{file_path}"

            if(checksum_value == file_sha1_value)
                log.info "Checksum match: expected:[#{checksum_value}] file:[#{file_sha1_value}]"
                log.info "No download is needed"
                
                result = false
            else
                log.info "Checksum didn't match: expected:[#{checksum_value}] file:[#{file_sha1_value}]"
                log.info "FIle will be deleted and re-downloading it: #{file_path}"
                
                result = true
            end

            result
        end

        def _get_file_sha1_value(path)
            sha1 = Digest::SHA1.file path
            sha1.hexdigest
        end

        def _delete_file(path)
            begin
                if File.exist? path
                    log.debug "Deleting file: #{path}"
                    FileUtils.rm_rf path
                    log.debug "Deleted file: #{path}"
                end
            rescue => exception
                log.error "Error while releting file: #{path} - error: #{exception}"
            end
        end

        def _download_file(src:, dst:, options: [])

            dst_folder = File.basename dst
            log.debug "Ensuring folder: #{dst_folder}"
            FileUtils.mkdir_p dst_folder

            options_string = options.join(' ')

            cmd = _get_download_tool_cmd % {src: src, dst: dst, options: options_string }                            
            data = {:out => [], :err => []}

            log.info "Running download: #{cmd}"
            log.info "Updates will be posted every 60 sec"

            Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
                { :out => stdout, :err => stderr }.each do |key, stream|
                    Thread.new do

                        last_time = Time.now 

                        until (raw_line = stream.gets).nil? do
                            
                            now_time = Time.now
                            should_report = (now_time - last_time) * 1000 > 60000
                            
                            if should_report == true
                                log.info "#{now_time} - batch download: pid: #{thread.pid}"
                                
                                log.info "  src: [#{src}]"
                                log.info "  dst: [#{dst}]"
                                log.info "  #{raw_line}"

                                last_time = Time.now 
                            end
                            
                        end
                        
                    end
                end
                
                thread.join 
            end

            log.info "Download completed!"

        end

        def _get_destination_path(resource)
            result = resource.destination_path
            result
        end

        def _get_destination_folder_path(resource)
            result =  File.dirname _get_destination_path(resource)
            FileUtils.mkdir_p result

            result
        end

        def execute_inline_scripts(home_folder, scripts)
            scripts.each do | script |
                run_cmd(cmd: "cd #{home_folder} && #{script}")
            end
        end

        def _process_resource_zip_folder(file_path:, force: false)

            folder_path = File.dirname file_path
            file_name   = File.basename file_path

            http_test_file_path = File.join(folder_path, "zip/metabox-http-test.txt")

            log.info "Checking is file exists: #{http_test_file_path}"
            should_zip  = !File.exists?(http_test_file_path)

            if force
                should_zip = true
            end

            if should_zip
                log.info "  - creating ZIP folder for file: #{file_name}"    

                home_folder = folder_path
                cmd_string = "7z -v500m a zip/dist.zip #{file_name}"   
                
                # hack to clean up /zip folder
                # zip would fail if it exists
                FileUtils.rm_rf "#{home_folder}/zip"

                result = run_cmd(cmd: cmd_string, pwd: home_folder)

                # crafting metabox-http-test file
                # this file is used to 
                # - ensure that ZIP packaging was done with a positive outcome
                # - check is resource exists before transferring it to Packer/Vagrant
                if result == true
                    _create_http_test_file folder_path
                else
                    error_message "Got non-0 exit code while packing archive. File was: #{file_path}"

                    log.error error_message
                    raise error_message
                end
            else
                log.info "  - ZIP folder exists for file: #{file_name}"    
            end
        end

        def _create_http_test_file(folder_path)
            file_path = File.join folder_path, "zip/metabox-http-test.txt"

            open(file_path, 'w') do |f|
                f.puts "yes"
            end
        end
    end

end