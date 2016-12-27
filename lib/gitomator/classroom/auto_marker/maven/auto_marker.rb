require 'gitomator/classroom/auto_marker/dockerized'
require 'gitomator/task'
require 'fileutils'
require 'nokogiri'



module Gitomator
  module Classroom
    module AutoMarker
      module Maven



        class PrepareAutoMarkerRepo < Gitomator::BaseTask

          attr_reader :source_repo_name
          attr_reader :local_root

          #
          # @param context
          # @param source_repo_name [String] An existing repo (that has a `solution` branch)
          # @param local_root [String] The local root of the auto-marker repo
          #
          def initialize(context, source_repo_name, local_root)
            super(context)
            @source_repo_name = source_repo_name
            @local_root       = File.absolute_path(File.expand_path(local_root))
          end


          def clone_url()
            if @clone_url.nil?
              repo = hosting.read_repo(source_repo_name)
              raise "Cannot find source repo, #{source_repo_name}" if repo.nil?
              @clone_url = repo.url
            end
            return @clone_url
          end


          def run
            if Dir.exists? local_root
              logger.info "Automarker #{local_root} already exists. No need to create it."
              return
            end

            logger.info "Clone #{clone_url} at #{local_root}"
            git.clone(clone_url, local_root)

            logger.info "Checkout the solution branch"
            git.checkout(local_root, "solution")

            logger.info "rm -rf #{File.join(local_root, '.git')}"
            FileUtils.rm_rf(File.join(local_root, '.git'))

            logger.info "Remove application code"
            remove_application_code()

            logger.info "Update pom.xml"
            update_pom_xml(File.join(local_root, 'pom.xml'))

            logger.info "Initialize Git repo and commit all files"
            git.init(local_root)
            git.add(local_root, '--all')
            git.commit(local_root, 'Initial commit')

            logger.info "done"
          end


          def remove_application_code()
              ['java', 'resources'].each do |x|
                dir = File.join(local_root, 'src', 'main', x)
                Dir.foreach(dir).each do |entry|
                  next if ['.', '..', '.gitkeep'].include? entry
                  FileUtils.rm_rf(File.join(dir, entry))
                end
              end
          end


          def update_pom_xml(path_to_pom_file)
              f = File.open(path_to_pom_file)
              pom = Nokogiri::XML(f)
              f.close

              # Read the current group-id, artifact-id and version
              group_id    = pom.xpath('xmlns:project/xmlns:groupId').first.content
              artifact_id = pom.xpath('xmlns:project/xmlns:artifactId').first.content
              version     = pom.xpath('xmlns:project/xmlns:version').first.content

              # Change the artifact_id
              pom.xpath('xmlns:project/xmlns:artifactId').first.content = artifact_id + '-automarker'

              # Add the application code as a dependency
              dependencies = pom.xpath('xmlns:project/xmlns:dependencies').first
              dependency   = Nokogiri::XML::Node.new "dependency", pom
              dependencies.add_child(dependency)

              dependency.add_child("<groupId>#{group_id}</groupId>")
              dependency.add_child("<artifactId>#{artifact_id}</artifactId>")
              dependency.add_child("<version>#{version}</version>")

              f = File.open(path_to_pom_file, 'w')
              pom.write_xml_to(f)
              f.close
          end

        end




        class AutoMarker < Gitomator::Classroom::AutoMarker::Dockerized

          def initialize(context, auto_marker_config, local_dir)
            super(context, auto_marker_config, local_dir)

            local_root = File.join(local_dir, 'auto_marker_repo')
            auto_marker_config.resources['automarker'] = local_root

            before_processing_any_repos do
              PrepareAutoMarkerRepo.new(context,
                auto_marker_config.auto_marker_source_repo, local_root
              ).run()
            end
          end

        end



      end
    end
  end
end
