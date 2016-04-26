require 'gitomator/classroom/auto_marker/base'
require 'gitomator/task/clone_repos'
require 'fileutils'


module Gitomator
  module Classroom
    module AutoMarker
      class Dockerized < Gitomator::Classroom::AutoMarker::Base

        attr_reader :work_dir, :docker_image

        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker]
        # @param work_dir [String] Path to an existing directory
        #
        def initialize(context, auto_marker_config, work_dir)
          super(context, auto_marker_config)
          raise "No such dir, #{work_dir}" unless Dir.exist? work_dir
          @work_dir = work_dir

          raise "Config missing 'docker_image'" if config.docker_image.nil?
          @docker_image = config.docker_image

          raise "Config missing 'run_script'" if config.run_script.nil?
          raise "No such file, #{config.run_script}." unless File.file?(config.run_script)
          
          before_auto_marking do
            logger.debug "TODO: Fetch auto-marker's docker image"
            Gitomator::Task::CloneRepos.new(context, config.repos, work_dir).run()
          end
        end


        def resources_dir(repo)
          return File.join(work_dir, 'resources', repo)
        end

        def results_dir(repo)
          return File.join(work_dir, 'results', repo)
        end


        def auto_mark(repo)
          create_resources_dir(repo)
          create_results_dir(repo)

          cmd = docker_run_command(repo, 'run.sh')
          logger.info(cmd)

          out = File.open(File.join(results_dir(repo), 'stdout.txt'), 'w')
          err = File.open(File.join(results_dir(repo), 'stderr.txt'), 'w')
          system({}, cmd, {:out => out, :err => err})
          [out, err].each {|f| f.close }
        end


        #
        # @return [String] The path to the resources directory
        #
        def create_resources_dir(repo)
          resources = resources_dir(repo)

          # Create a fresh new resources dir ...
          FileUtils.remove_dir(resources) if Dir.exist? resources
          FileUtils.mkdir_p(resources)

          # Copy the `solution`
          FileUtils.cp_r(File.join(work_dir, repo), File.join(resources, 'solution'))

          # Copy `run.sh`
          run_script = File.join(resources, 'run.sh')
          FileUtils.cp(config.run_script, run_script)
          File.chmod(0777, run_script)

          # Copy additional resources
          (config.resources || {}).each do |name, path_on_host|
            FileUtils.cp_r(path_on_host, File.join(resources, name))
          end
        end


        def create_results_dir(repo)
          results = results_dir(repo)
          FileUtils.mkdir_p(results) unless Dir.exist? results
        end



        def docker_run_command(repo, run_script)
          cmd  = "docker run --rm -it "
          cmd += "-v #{File.absolute_path(resources_dir(repo))}:/root/resources:ro "
          cmd += "-v #{File.absolute_path(results_dir(repo))}:/root/results:rw "
          cmd += "-e \"GITOMATOR_RESOURCES=/root/resources\" "
          cmd += "-e \"GITOMATOR_RESULTS=/root/results\" "
          cmd += "#{docker_image} "
          cmd += "/bin/sh /root/resources/#{run_script}"

          return cmd
        end


      end
    end
  end
end
