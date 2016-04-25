require 'gitomator/task'
require 'gitomator/task/clone_repos'
require 'tmpdir'
require 'fileutils'

module Gitomator
  module Classroom
    module AutoMarker



      class Base < Gitomator::BaseTask

        attr_reader :config

        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker] Parsed configuration object (TODO: Implement it as a subclass of Gitomator::Classroom::Assignment)
        # @param assignment_config [Gitomator::Classroom::Assignment]
        #
        def initialize(context, auto_marker_config)
          super(context)
          @config = auto_marker_config
          @blocks = { :before => [], :after => [] }
        end


        def run()
          @blocks[:before].each {|b| self.instance_exec(&b) }

          # Keep the auto-marker results, for each submission (i.e. each repo)
          repo2mark  = {}
          repo2error = {}

          config.repos.each_with_index do |repo, index|
            logger.debug "#{repo} (#{index + 1} out of #{config.repos.length})"
            begin
              repo2mark[repo] = auto_mark(repo)
            rescue => e
              logger.error "#{repo} : #{e}\n#{e.backtrace.join("\n\t")}"
              repo2error[repo] = e
            end
          end

          @blocks[:after].each {|b| self.instance_exec(repo2mark, repo2error, &b) }
        end



        #
        # @param repo [String]
        # @return Object
        #
        def auto_mark(repo)
          raise "Unimplemented"
        end


        #
        # Inject a block that will run before any auto-marking takes place.
        # The blocks takes no arguments, and doesn't (need to) return any specific value.
        #
        def before_auto_marking(&block)
          @blocks[:before].push block
        end

        #
        # Inject a block that will run after all auto-marking took place.
        #
        # @yield [repo2mark, repo2error] A block that processes the auto-marker's results.
        # @yieldparam [Hash<String,Object>] repo2mark
        # @yieldparam [Hash<String,Error>]  repo2error
        #
        def after_auto_marking(&block)
          @blocks[:after].push block
        end


      end






      class DockerizedAutoMarker < Gitomator::Classroom::AutoMarker::Base

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
        end



        def auto_mark(repo)
          # Create the resources dir (i.e. INPUT)
          resources_dir = create_resources_dir(repo)
          # Create the results dir (i.e. OUTPUT)
          results_dir   = create_results_dir(repo)
          # Create the run script (i.e. Auto-marker)
          run_script = File.join(resources_dir, 'run.sh')
          File.open(run_script, 'w') { |f| write_run_script(f, repo) }
          File.chmod(0777, run_script)

          cmd = docker_run_command(repo, resources_dir, results_dir, 'run.sh')
          logger.info(cmd)

          out = File.open(File.join(results_dir, 'stdout.txt'), 'w')
          err = File.open(File.join(results_dir, 'stderr.txt'), 'w')
          system({}, cmd, {:out => out, :err => err})
          [out, err].each {|f| f.close }
        end



        #
        # @return [String] The path to the resources directory
        #
        def create_resources_dir(repo)
          resources_dir = File.join(work_dir, 'resources', repo)
          FileUtils.mkdir_p(resources_dir) unless Dir.exist? resources_dir

          # Copy the repo to the resources dir
          unless Dir.exist? File.join(resources_dir, repo)
            FileUtils.cp_r(File.join(work_dir, repo), File.join(resources_dir, repo))
          end

          return resources_dir
        end


        def create_results_dir(repo)
          path = File.join(work_dir, 'results', repo)
          FileUtils.mkdir_p(path) unless Dir.exist? path
          return path
        end


        def write_run_script(file, repo)
          file << "echo \"Hello from Gitomator Classroom\"\n"
          file << "echo \"Auto-marking #{repo}\"\n"
        end



        def docker_run_command(repo, resources_dir, results_dir, run_script)
          cmd  = "docker run --rm -it "
          cmd += "-v #{File.absolute_path(resources_dir)}:/root/resources:ro "
          cmd += "-v #{File.absolute_path(results_dir)}:/root/results:rw "
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





      class JavaMavenAutoMarker < Gitomator::Classroom::AutoMarker::DockerizedAutoMarker

        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker]
        # @param work_dir [String] Path to an existing directory
        #
        def initialize(context, auto_marker_config, work_dir)
          super(context, auto_marker_config, work_dir)

          before_auto_marking do
            Gitomator::Task::CloneRepos.new(context, config.repos, work_dir).run()
            logger.debug "TODO: Create and/or clone auto-marker to #{work_dir}"
            logger.debug "TODO: Fetch auto-marker's docker image"
          end

          after_auto_marking do |repo2mark, repo2error|
            logger.info "#{repo2mark.length} repo(s) marked successfully, #{repo2error.length} error(s)."
            logger.debug "Marks: #{repo2mark}"
            logger.debug "Errors: #{repo2error}"
          end
        end


        def write_run_script(file, repo)
          file << "cd\n"

          # Clone the repos from the read-only resources dir, to the home directory
          file << "git clone $GITOMATOR_RESOURCES/#{repo}\n"
          file << "git clone $GITOMATOR_RESOURCES/automarker\n"

          # Install the student's solution, using Maven
          file << "cd #{repo}\n"
          file << "mvn install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -B -V\n"
          file << "cd\n"

          # Run the automarker
          file << "cd automarker\n"
          file << "mvn clean\n"
          file << "mvn test -B\n"
          file << "cd\n"

          # Copy the results ...
          file << "cp -r automarker/target/surefire-reports $GITOMATOR_RESULTS/\n"
          file << "cd\n"
        end


        def create_resources_dir(repo)
          resources_dir = super(repo)
          unless Dir.exist? File.join(resources_dir, 'automarker')
            FileUtils.cp_r(File.join(work_dir, 'automarker'), File.join(resources_dir, 'automarker'))
          end
          return resources_dir
        end


        def docker_image
          return 'joeyfreund/automarker-intro-fall-2015'
        end

      end




    end
  end
end
