require 'gitomator/classroom/auto_marker/base'
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
      #  0. Docker image
      #  1. Resources (i.e. files and folders, used as "inputs" to the automarker)
      #  2. Results (i.e. folder, where the automarker can save its results)
      #  3. Auto-marker Script
      #
      # This task takes care of mounting the resources and results as container
      # volumes, and running the script.
      #
      class Dockerized < Gitomator::Classroom::AutoMarker::Base

        attr_reader :docker_image

        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker]
        #
        def initialize(context, auto_marker_config)
          super(context, auto_marker_config)

          raise "Config missing 'docker_image'" if config.docker_image.nil?
          @docker_image = config.docker_image

          @automarker_script = config.automarker_script || 'run'

          raise "Config missing 'results_dir'" if config.results_dir.nil?
          @results_dir = config.results_dir
          raise "No such dir, #{@results_dir}" unless Dir.exist? @results_dir

          before_auto_marking do
            logger.debug "TODO: Fetch auto-marker's docker image"
          end
        end


        def results_dir(repo)
          File.join(@results_dir, repo)
        end


        def auto_mark(repo)
          cmd = docker_run_command(repo)
          logger.info(cmd)

          File.open(File.join(results_dir(repo), 'out.txt'), 'w') do |out|
            File.open(File.join(results_dir(repo), 'err.txt'), 'w') do |err|
              res = system({}, cmd, {:out => out, :err => err})
              logger.debug "Shell command returned #{res}"
            end
          end
        end


        def docker_run_command(repo)
          cmd  = "docker run --rm -it "

          cmd += "-v #{File.absolute_path(results_dir(repo))}:/root/results:rw "
          cmd += "-e \"GITOMATOR_RESULTS=/root/results\" "

          if config.resources
            # Mount all specified resources
            config.resources.each do |name, path|
              path = File.absolute_path(path.gsub('$REPO$', repo))
              cmd += "-v #{path}:/root/resources/#{name}:ro "
            end
            # And set the GITOMATOR_RESOURCES environment variable
            cmd += "-e \"GITOMATOR_RESOURCES=/root/resources\" "
          end

          cmd += "#{docker_image} "
          cmd += "/bin/sh /root/resources/#{@automarker_script}"

          return cmd
        end


      end
    end
  end
end
