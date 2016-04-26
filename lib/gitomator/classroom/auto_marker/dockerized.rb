require 'gitomator/classroom/auto_marker/base'
require 'gitomator/task/clone_repos'
require 'fileutils'


module Gitomator
  module Classroom
    module AutoMarker
      class Dockerized < Gitomator::Classroom::AutoMarker::Base

        attr_reader :work_dir

        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker]
        # @param work_dir [String] Path to an existing directory
        #
        def initialize(context, auto_marker_config, work_dir)
          super(context, auto_marker_config)
          raise "No such dir, #{work_dir}" unless Dir.exist? work_dir
          @work_dir = work_dir

          before_auto_marking do
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

          # Create the run script (i.e. Auto-marker)
          run_script = File.join(resources_dir(repo), 'run.sh')
          File.open(run_script, 'w') { |f| write_run_script(f, repo) }
          File.chmod(0777, run_script)

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
          # Create a fresh new resources dir
          FileUtils.remove_dir(resources) if Dir.exist? resources
          FileUtils.mkdir_p(resources)
          # Copy the repo into the resources dir
          FileUtils.cp_r(File.join(work_dir, repo), File.join(resources, repo))
        end


        def create_results_dir(repo)
          results = results_dir(repo)
          FileUtils.mkdir_p(results) unless Dir.exist? results
        end


        def write_run_script(file, repo)
          file << "echo \"Hello from Gitomator Classroom\"\n"
          file << "echo \"Auto-marking #{repo}\"\n"
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


        def docker_image
          return 'alpine'
        end


      end
    end
  end
end
