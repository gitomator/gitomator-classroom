require 'gitomator/task/base_repos_task'
require 'gitomator/task/clone_repos'
require 'fileutils'


module Gitomator
  module Classroom
    module AutoMarker

      #
      # A docker-based auto marker.
      #
      # Essentially, this auto-marker loads the following pieces of information
      # from a configuration file:
      #  1. An executable script
      #  2. Read-only resources (i.e. files/folders, used as inputs)
      #  3. Environment variables
      #  4. Docker image
      #
      # This task takes care of mounting the resources and results as container
      # volumes, and running the script.
      #
      class Dockerized < Gitomator::Task::BaseReposTask

        attr_reader :config

        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker]
        # @param local_dir [String] A local directory where the repos will be (or have been) cloned.
        #
        def initialize(context, auto_marker_config, local_dir)
          super(context, auto_marker_config.repos, local_dir)

          @config = auto_marker_config

          before_processing_any_repos do
            cmd = "docker pull #{@config.docker_image}"
            logger.info "#{cmd}\n\n ** Note: Pulling an image may take a while **\n\n"
            system({}, cmd, {})
          end
        end


        def local_root(repo)
          normalize_path(File.join(local_dir, repo))
        end


        def process_repo(repo, index)
          cmd = docker_run_command(repo)
          logger.info(cmd)
          File.open(File.join(local_root(repo), 'out.txt'), 'w') do |out|
            File.open(File.join(local_root(repo), 'err.txt'), 'w') do |err|
              system({}, cmd, {:out => out, :err => err})
            end
          end
        end


        def docker_run_command(repo)
          cmd  = "docker run --rm -it "

          # Mount the executable auto-marker script
          path = normalize_path(config.automarker_script)
          cmd += "-v #{path}:/root/run "

          # Mount read-only `resources`
          resources = config.resources.merge({
            'solution' => local_root(repo)
          })
          resources.each do |name, path|
            cmd += "-v #{normalize_path(path)}:/root/resources/#{name}:ro "
          end

          # Mount a writable `results` directory (i.e. output directory)
          cmd += "-v #{local_root(repo)}:/root/results:rw "

          # Setup environment variables
          env = config.env.merge({
            'GITOMATOR_RESOURCES' => '/root/resources',
            'GITOMATOR_RESULTS'   => '/root/results'
          })
          env.each do |name, value|
            cmd += "-e \"#{name}=#{value}\" "
          end

          # Specify the docker image, and the command to run
          return "#{cmd} #{config.docker_image} /bin/sh /root/run"
        end


        def normalize_path(path)
          path = File.absolute_path(File.expand_path(path))
          raise "No such file/directory, #{path}" unless File.exist?(path)
          return path
        end


      end
    end
  end
end
