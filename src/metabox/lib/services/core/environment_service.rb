
module Metabox

    class EnvironmentService < ServiceBase

        @http_server_addr;
        @local_metabox_values;

        @revisions_flag;

        def initialize
            @local_metabox_values = {}
        end

        def name 
            "metabpx::core::environment"
        end

        def __env 
            ENV.to_hash
        end

        def get_env_variables
            result = __env

            _fill_system_vars result
       
            result
        end

        def set_metabox_variables(hash)
            hash.each { | name, value |
                @local_metabox_values[name] = value
            }
        end

        def get_metabox_variables(raise_on_missing_vars: true, exclude_variables: [])
            result = {}

            if exclude_variables.nil?
                exclude_variables = []
            end

            __env.each { | name, value |
                if name.upcase.include? "METABOX_"
                    result[name] = value
                end
            }

            @local_metabox_values.each { | name, value |
                if name.upcase.include? "METABOX_"
                    result[name] = value
                end
            }

            _fill_system_vars result, raise_on_missing_vars

            exclude_variables.each do | exclude_variable_name |
                result.delete(exclude_variable_name)
            end

            result
        end

        def get_metabox_vagrant_provision_tags
            result = __env.fetch('METABOX_VAGRANT_PROVISION_TAGS', nil)

            if !result.nil? 
                return result.split('+')
            end

            nil
        end

        def get_metabox_log_level
            __env.fetch('METABOX_LOG_LEVEL', 'INFO')
        end

        def set_metabox_http_server_addr(http_addr)
            @http_server_addr = http_addr
        end

        def get_metabox_http_server_addr
            if !@http_server_addr.nil?
                return @http_server_addr
            end

            return __env.fetch('METABOX_HTTP_ADDR', nil)
        end

        def get_metabox_document_dirs
            result = []

            fodler_paths =  __env.fetch('METABOX_DOCUMENT_FOLDERS', '~/.metabox_documents').split(',')
            
            fodler_paths.each do | fodler_path | 
                result << File.expand_path(fodler_path.strip)
            end

            result
        end

        def set_metabox_working_dir
            
        end

        def get_metabox_working_dir
            result = File.expand_path(__env.fetch('METABOX_WORKING_DIR', "~/.metabox_home"))
            FileUtils.mkdir_p result

            result
        end

        def get_metabox_packer_cache_dir
            result = File.join get_metabox_working_dir, "packer_cache"
            
            if !File.exists? result
                FileUtils.mkdir_p result
            end

            result
        end

        def get_metabox_branches_dir
            result = File.join get_metabox_working_dir, "metabox_branches"
            
            _ensure_folder result
            
            result
        end

        def get_metabox_packer_dir
            result = File.join get_metabox_branches_dir, get_metabox_branch
            result = File.join result, "packer_builds"

            _ensure_folder result
            
            result
        end

        def get_metabox_vagrant_dir
            result = File.join get_metabox_branches_dir, get_metabox_branch
            result = File.join result, "vagrant_builds"
            
            _ensure_folder result
            
            result
        end

        def get_metabox_vagrant_delete_boxfile?
            result = __env.fetch('METABOX_VAGRANT_DELETE_BOX_FILE', true)

            return !result.nil? 
        end

        def get_metabox_vagrant_box_shadow_folders
            result = [] 
            
            folders_stirng = __env.fetch('METABOX_VAGRANT_BOX_SHADOW_FOLDERS', nil)

            if !folders_stirng.nil? 
                folders = folders_stirng.split(',')

                folders.each do | folder |
                    expanded_folder = File.expand_path folder

                    _ensure_folder expanded_folder

                    result << expanded_folder
                end
            end
            
            result
        end

        def get_metabox_packer_tmp_dir
            result = File.join get_metabox_working_dir, "packer_tmp"

            log.debug "Creating folder: #{result}"
            FileUtils.mkdir_p result

            result
        end

        def get_metabox_logs_folder
            result = File.join get_metabox_working_dir, ".logs"

            _ensure_folder result

            result
        end

        def get_metabox_config_folder
            result = File.join get_metabox_working_dir, ".config"

            _ensure_folder result

            result
        end

        def get_metabox_vagrant_log
            result = __env.fetch('METABOX_VAGRANT_LOG', nil)
            result
        end
        
        def get_metabox_packer_log_path
            result = File.join get_metabox_logs_folder, "packer.log"
            result
        end

        def get_metabox_packer_log
            result = __env.fetch('METABOX_PACKER_LOG', "1")
            result
        end
        
        def get_metabox_vagrant_update_check_disable
            result = __env.fetch('METABOX_VAGRANT_BOX_UPDATE_CHECK_DISABLE', "1")
            result
        end

        def get_metabox_vagrant_home
            result = File.join get_metabox_working_dir, "vagrant_home"

            _ensure_folder result

            result
        end

        def get_metabox_vagrant_vm_folder
            result = File.join get_metabox_working_dir, "vagrant_vms/default"

            _ensure_folder result

            result
        end

        def get_metabox_packer_vm_folder
            result = File.join get_metabox_working_dir, "packer_vms/default"

            _ensure_folder result

            result
        end

        def enable_revisions
            @revisions_flag = "1"
        end

        def disable_revisions
            @revisions_flag = nil
        end

        def metabox_features_revisions?
            result = __env.fetch('METABOX_FEATURES_REVISIONS', @revisions_flag)
            
            result != nil
        end

        def get_metabox_packer_checkpoint_disable
            result = __env.fetch('METABOX_PACKER_CHECKPOINT_DISABLE', "1")
            result
        end

        def get_metabox_default_downloads_path
            result = File.join get_metabox_working_dir, "metabox_downloads"

            _ensure_folder result

            result
        end

        def get_metabox_downloads_path
            result = __env.fetch('METABOX_DOWNLOADS_PATH', get_metabox_default_downloads_path)

            _ensure_folder result

            log.debug "Creating 'metabox-http-test.txt' file in: #{result}"
            _create_metabox_http_test_file(result)
            
            result
        end

        def get_metabox_fileset_threads(default_value = 5)
            result = __env.fetch('METABOX_FILESET_THREADS', default_value)
            result
        end

        def get_metabox_download_tool_cmd(default_value = "wget -O %<dst>s \"%<src>s\" %<options>s")
            result = __env.fetch('METABOX_FILESET_THREADS', default_value)
            result
        end

        private

        def _ensure_folder(dir_path)
            log.debug "Ensuring folder: #{dir_path}"
            
            FileUtils.mkdir_p dir_path
        end

        def _create_metabox_http_test_file(dir_path)
            file_name = 'metabox-http-test.txt'
            
            src = "#{METABOX_ROOT}/templates/files/#{file_name}"
            dst = File.join dir_path, file_name

            open(dst, 'w') do |f|
                f.puts File.read(src)
            end
        end

        def _fill_system_vars(hash, raise_on_missing_vars = true)

            # metabox vars
            hash["METABOX_GIT_BRANCH"] = get_metabox_branch
            hash["METABOX_DOWNLOADS_PATH"] = get_metabox_downloads_path
            hash["METABOX_WORKING_DIR_EXPANDED"] = File.expand_path get_metabox_working_dir

            hash["METABOX_BRANCHES_DIR"] = get_metabox_branches_dir
            hash["METABOX_PACKER_BUILD_DIR"] = get_metabox_packer_dir
            hash["METABOX_VAGRANT_BUILD_DIR"] = get_metabox_vagrant_dir

            # packer vars
            # https://www.packer.io/docs/other/environment-variables.html
            hash["PACKER_CACHE_DIR"] = get_metabox_packer_cache_dir
            hash["PACKER_CACHE"] = get_metabox_packer_cache_dir

            hash["PACKER_LOG"] = get_metabox_packer_log
            hash["PACKER_LOG_PATH"] = get_metabox_packer_log_path
            hash["TMPDIR"] = get_metabox_packer_tmp_dir
            hash["CHECKPOINT_DISABLE"] = get_metabox_packer_checkpoint_disable
             
            # vagrant vars
            # https://www.vagrantup.com/docs/other/environmental-variables.html
            if !get_metabox_vagrant_log.nil?
                hash["VAGRANT_LOG"] = get_metabox_vagrant_log    
            end
            
            hash["VAGRANT_BOX_UPDATE_CHECK_DISABLE"] = get_metabox_vagrant_update_check_disable
            hash["VAGRANT_HOME"] = get_metabox_vagrant_home

            if !@http_server_addr.nil?
                hash["METABOX_HTTP_ADDR"] = @http_server_addr
            end
            
        end

    end
end