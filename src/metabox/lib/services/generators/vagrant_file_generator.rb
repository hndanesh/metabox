module Metabox

    module Document

        class VagrantFileGenerator < DocumentGeneratorBase

            def name
                "metabox::document::generators::vagrant_file"
            end

            def process(context:, resources:) 
                _internal_process(resources)
            end

            private 

            def _internal_process(resources)
                dir = env_service.get_metabox_vagrant_dir
            
                _create_vagrant_file(dir)
            end

            def _create_vagrant_file(dir_path)

                log.info "Updating Vagrantfile.."

                src = "#{METABOX_ROOT}/templates/vagrant/Vagrantfile"
                dst = File.join dir_path, 'Vagrantfile'
    
                log.info " - src -> : #{src} -> #{dst}"

                open(dst, 'w') do |f|


                    f.puts File.read(src)
                end
            end
        end

    end
end