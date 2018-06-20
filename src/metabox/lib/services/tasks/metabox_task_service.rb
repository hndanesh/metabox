
require_relative "task_service_base"
require 'json'

module Metabox

    class MetaboxTaskService < TaskServiceBase

        @packer_plugins;

        def initialize
            @packer_plugins = [
                {
                    name: "packer-builder-vagrant",
                    mac_src_url: "https://github.com/themalkolm/packer-builder-vagrant/releases/download/v2017.10.17/packer-1.0.4_packer-builder-vagrant_darwin_amd64",
                    mac_plugin_file_name: "packer-builder-vagrant",

                    win_src_url: "https://github.com/themalkolm/packer-builder-vagrant/releases/download/v2017.10.17/packer-1.0.4_packer-builder-vagrant_windows_amd64.exe",
                    win_plugin_file_name: "packer-builder-vagrant.exe"   
                }
            ]
        end

        def name 
            "metabox::tasks:metabox"
        end

        def rake_alias 
            "metabox"
        end

        def configure(params)
            config_common params
            config_vagrant params
            config_packer params
        end

        def configure_metabox(params)
            log.info "Bootstrapping Metabox..."
            
            log.info "Running OS specific tasks..."
            if os_service.is_windows?
                _bootstrap_windows
            else
                _bootstrap_mac
            end
            
            log.info "Running common tasks..."
            _bootstrap_common

            log.info "Finished bootstrapping Metabox..."
        end

        def configure_packer(params)
            log.info "Configuring Packer..."

            @packer_plugins.each do | plugin |
                if os_service.is_windows? 
                    _install_packer_plugin(
                        name: plugin[:name],
                        src_url: plugin[:win_src_url],
                        plugin_file_name: plugin[:win_plugin_file_name],
                    )
                else
                    _install_packer_plugin(
                        name: plugin[:name],
                        src_url: plugin[:mac_src_url],
                        plugin_file_name: plugin[:mac_plugin_file_name],
                    )
                end
    
            end
        end

        def configure_vagrant(params)
            log.info "Configuring Vagrant..."
            working_dir = env_service.get_metabox_vagrant_dir

            plugins = [
                "vagrant-hostmanager",
                "vagrant-reload",
                "vagrant-serverspec"
            ]

            plugins.each do | plugin | 
                cmd = "vagrant plugin install #{plugin}"
        
                track_execution("Executing cmd") { os_service.run_cmd(cmd: cmd, pwd: working_dir, is_dry_run: is_dry_run? ) }
            end
        end

        def validate_config(params)

            log.info "Validating 3rd party tools..."
            _validate_dependencies(params)

            log.info "Validating packer plugins..."
            _validate_packer(params)

            log.info "Validating vagrant plugins..."
            _validate_vagrant(params)
        end

        def version(params)
            _print_version_raw
        end

        def init(params)
            # create initial metabox file in the current directory
            _create_metabox_file(Dir.pwd)
        end

        def _create_metabox_file(dir_path)

            log.info "Creating Metaboxfile.."

            src = "#{METABOX_ROOT}/templates/metabox/Metaboxfile.rb"
            dst = File.join dir_path, 'Metaboxfile.rb'

            log.debug " - src: #{src}"
            log.debug " - dst: #{dst}"

            open(dst, 'w') do |f|
                f.puts File.read(src)
            end
        end

        def build_image(params)
            log.info "Building packer image and adding it to Vagrant..."

            _execute_workflow(tasks: [
                {
                    name: "resource:generate",
                    params: [],
                    description: "generating resources"
                },

                {
                    name: "resource:list",
                    params: [],
                    description: "listing resources"
                },

                {
                    name: "packer:build",
                    params: params,
                    description: "building Packer image"
                },

                {
                    name: "vagrant:add",
                    params: params,
                    description: "adding image to Vagrant"
                }
            ])
        end

        def start_vm(params)
            log.info "Starting virtual machine..."

            _execute_workflow(tasks: [
                {
                    name: "resource:generate",
                    params: [],
                    description: "generating resources"
                },

                {
                    name: "resource:list",
                    params: [],
                    description: "listing resources"
                },

                {
                    name: "vagrant:up",
                    params: params,
                    description: "starting virtual machine"
                }
            ])
        end

        def halt_vm(params)
            log.info "Halting virtual machine..."

            _execute_workflow(tasks: [
                {
                    name: "resource:generate",
                    params: [],
                    description: "generating resources"
                },

                {
                    name: "resource:list",
                    params: [],
                    description: "listing resources"
                },

                {
                    name: "vagrant:halt",
                    params: params,
                    description: "starting virtual machine"
                }
            ])
        end

        def reload_vm(params)
            log.info "Reloading virtual machine..."

            _execute_workflow(tasks: [
                {
                    name: "resource:generate",
                    params: [],
                    description: "generating resources"
                },

                {
                    name: "resource:list",
                    params: [],
                    description: "listing resources"
                },

                {
                    name: "vagrant:reload",
                    params: params,
                    description: "starting virtual machine"
                }
            ])
        end

        def destroy_vm(params)
            log.info "Destroying virtual machine..."
       
            begin
                # update METABOX_FEATURES_REVISIONS flag
                env_service.enable_revisions

                _execute_workflow(tasks: [
                    {
                        name: "resource:generate",
                        params: [],
                        description: "generating resources"
                    },

                    {
                        name: "resource:list",
                        params: [],
                        description: "listing resources"
                    },

                    {
                        name: "vagrant:destroy",
                        params: params,
                        description: "starting virtual machine"
                    }
                ])
            ensure
                env_service.disable_revisions
            end
        end

        def apply_revision(params)
            log.info "Applying revision to virtual machine..."

            vm = params[0]
            revision_names =  params[1]

            if revision_names.nil? 
                revision_names = ""
            end

            revision_names = revision_names.gsub(',', '+')

            _execute_workflow(tasks: [
                {
                    name: "metabox:start_vm",
                    params: [
                        "#{vm}",
                        "--provision",
                        "provision_tags=#{revision_names}"
                    ],
                    description: "generating resources"
                }
            ])
        end

        private

        def _print_version_raw
            puts Metabox::VERSION
        end

        def _validate_packer(params)

            target_folder = _get_packer_plugin_folder
            
            positive = []
            negative = []

            @packer_plugins.each do | plugin |

                plugin_name = plugin[:name]
                
                if os_service.is_windows? 
                    target_file = File.join target_folder, plugin[:win_plugin_file_name]
                else
                    target_file = File.join target_folder, plugin[:mac_plugin_file_name]
                end

                result = File.exist? target_file

                if result
                    positive << "[+] plugin: #{plugin_name} : #{target_file}"
                else
                    negative << "[-] plugin: #{plugin_name} : file does not exist - #{target_file}"
                end
                
            end

            log.info "\n    " + positive.join(" \n")

            if !negative.empty?
                log.error "\n   " + negative.join(" \n")
            end
        end

        def _validate_vagrant(params)
            cmd = "vagrant plugin list"

            run_cmd(cmd: cmd, silent: true)
        end

        def  _validate_dependencies(param)
            if os_service.is_windows?
                _validate_win_dependencies
            else
                _validate_mac_dependencies
            end

            # TODO - validate gems, sinatra has to be there
        end

        def _get_packer_plugin_folder
            target_folder = File.expand_path("~/.packer.d/plugins")
            if os_service.is_windows? 
                app_data_folder = ENV['APPDATA']
                target_folder = File.expand_path("#{app_data_folder}\\packer.d\\plugins")
            end

            log.debug "Ensuring target_folder: #{target_folder}"
            FileUtils.mkdir_p target_folder

            target_folder
        end

        def _install_packer_plugin(name:, src_url:, plugin_file_name:)
            log.info "Installing plugin: #{name}"
           
            log.debug "src: #{src_url}"
            log.debug "plugin_file_name: #{plugin_file_name}"

            target_folder = _get_packer_plugin_folder

            target_file = File.join target_folder, plugin_file_name
            log.debug "target_file: #{target_file}"
            
            if File.exists? target_file
                log.info "  file exist: #{target_file}"
            else    
                install_script = "wget -O #{target_file} #{src_url}"
                run_cmd(cmd: install_script)
            end
        end

        def _common_cmd_dependencies
            [
                "git",
                "7z",
                "vagrant",
                "packer",
                "virtualbox",
                "ruby",
                "gem",
                "rake"
            ]
        end

        def _validate_win_dependencies
            _check_cmd_dependencies(["wget.exe"])
           _check_cmd_dependencies(_common_cmd_dependencies)
        end

        def _validate_mac_dependencies
            _check_cmd_dependencies(["wget"])
            _check_cmd_dependencies(_common_cmd_dependencies)
        end

        def _check_cmd_dependencies(tools)
            
            result = []
            negative_result = []

            is_valid = true

            tools.each do | tool_name |
                cmd = "which #{tool_name}"

                if os_service.is_windows? 
                    cmd = "powershell -Command 'if ((Get-Command -Name \"#{tool_name}\" -ErrorAction SilentlyContinue) -ne $null) { return 0; } else { return 1; }'"
                end

                cmd_result = run_cmd(cmd: cmd, silent: true)

                result_indicator = "[-]"
                if cmd_result 
                    result_indicator = "[+]"
                else 
                    is_valid = false
                    negative_result < "#{result_indicator} #{cmd}"
                end
                    
                result << "#{result_indicator} #{cmd}"
            end

            result_string = "\n    " + result.join("\n    ")
            negative_result_string = "\n    " + negative_result.join("\n    ")
            
            log.info result_string

            if !is_valid
                log.error negative_result_string
                raise negative_result_string
            end

        end

        def _bootstrap_windows
            log.info "Windows platform was detected."
        end

        def _bootstrap_mac
            log.info "MacOS platform was detected."
        end

        def _bootstrap_common
            log.info "Installing Ruby gems..."
            _get_ruby_gems.each do | cmd |
                log.info "  - #{cmd}"
                run_cmd(cmd: cmd)
            end
        end

        def _get_ruby_gems
            [
                "gem install sinatra --no-ri --no-rdoc"
            ]
        end

    end

end