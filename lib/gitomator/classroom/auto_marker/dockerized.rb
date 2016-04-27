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

        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker]
        #
        def initialize(context, auto_marker_config)
          super(context, auto_marker_config)

          before_auto_marking do
            cmd = "docker pull #{config.docker_image}"
            logger.info "#{cmd}\nNote: Downloading may take a while."
            system({}, cmd, {})
          end
        end


        def results_dir(repo)
          File.join(config.results_dir, repo)
        end


        def auto_mark(repo)
          cmd = docker_run_command(repo)
          logger.info(cmd)
          File.open(File.join(results_dir(repo), 'out.txt'), 'w') do |out|
            File.open(File.join(results_dir(repo), 'err.txt'), 'w') do |err|
              system({}, cmd, {:out => out, :err => err})
            end
          end
        end


        def docker_run_command(repo)
          cmd  = "docker run --rm -it "

          # Mount the auto-marker script
          path = File.absolute_path(config.automarker_script)
          cmd += "-v #{path}:/root/run "

          # Mount the results directory (and set environment variable)
          path = File.absolute_path(results_dir(repo))
          cmd += "-v #{path}:/root/results:rw "
          cmd += "-e \"GITOMATOR_RESULTS=/root/results\" "

          # Mount the (read-only) resources directory (and set environment variable)
          config.resources.each do |name, path|
            path = File.absolute_path(path.gsub('$REPO$', repo))
            cmd += "-v #{path}:/root/resources/#{name}:ro "
          end
          cmd += "-e \"GITOMATOR_RESOURCES=/root/resources\" "

          # Specify the docker image, and the command to run
          cmd += "#{config.docker_image} "
          cmd += "/bin/sh /root/run"

          return cmd
        end


      end
    end
  end
end
