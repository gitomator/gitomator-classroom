require_relative 'auto_marker_base.rb'
require_relative '../../../lib/github_classroom/client2'
require_relative '../../../lib/github_classroom/script_util'
require 'nokogiri'
require 'fileutils'


module CSC301

  class JUnitMavenAutoMarker < AutoMarkerBase

    #---------------------------------------------------------------------------
    # Overrides

    def automarker_init()
      super

      if _automarker_repo_exists?
        puts "#{_automarker_repo_name} already exists, no need to create it."
      else
        _create_automarker_repo()
      end
    end


    def automarker_mark(handout_id, out_log, err_log)
      if should_run_junit_tests? handout_id

        # FIXME: This is a hack, need to clean it up
        puts "Creating OUT and ERR logs"
        out_log = File.open(File.join(handout_automarker_dir(handout_id), 'out.log'), 'w')
        err_log = File.open(File.join(handout_automarker_dir(handout_id), 'err.log'), 'w')
        begin
          _checkout_last_commit_before_the_deadline(handout_id, out_log, err_log)
          _run_junit_tests_in_docker(handout_id, out_log, err_log)
          _copy_junit_reports_to_handout_automarker_dir(handout_id)
        ensure
          [out_log, err_log].each {|f| f.close unless f.nil?}
        end

      else
        puts "No need to run JUnit test"
      end

      if Dir.exists? handout_junit_reports_dir(handout_id)
        return junit_reports2mark(handout_id)
      else
        return 0
      end
    end

    #---------------------------------------------------------------------------
    # "Abstract" methods

    def should_run_junit_tests?(handout_id)
      false
    end

    def junit_reports2mark(handout_id)
      raise "Unimplemented"
    end

    def docker_image_name()
      raise "Unimplemented"
    end

    #---------------------------------------------------------------------------

    #
    # out, WritableStream
    # err, WritableStream
    #
    def _checkout_last_commit_before_the_deadline(handout_id, out_log, err_log)
      commit = _get_last_commit_before_the_deadline(handout_id)

      commit_info = "#{commit.oid} - #{commit.message}  (#{commit.author[:name]}, #{commit.author[:time]})"

      out_log << "Checking out #{commit_info} ... \n\n"
      out_log.flush

      # Make sure we're at the tip of the master branch
      _run_command("git checkout master",
        {:chdir => handout_root_dir(handout_id), :out => out_log, :err => err_log})
      _run_command("git checkout #{commit.oid}",
        {:chdir => handout_root_dir(handout_id), :out => out_log, :err => err_log})
    end


    def _get_last_commit_before_the_deadline(handout_id)
      repo = Rugged::Repository.new(handout_root_dir(handout_id))
      walker = Rugged::Walker.new(repo)
      walker.sorting(Rugged::SORT_DATE)
      walker.push(repo.head.target)
      return walker.find {|commit| commit.author[:time] < conf.deadline}
    end


    def _run_junit_tests_in_docker(handout_id, out_log, err_log)
      # Run the unit tests ...
      cmd  = "docker run --rm -it "
      cmd += "-v #{File.absolute_path(_automarker_repo_root)}:/root/automarker:rw "
      cmd += "-v #{File.absolute_path(handout_root_dir(handout_id))}:/root/solution:rw "
      cmd += "#{docker_image_name} "
      cmd += "/bin/sh -c 'cd /root/solution;mvn install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -B -V;cd /root/automarker;mvn clean;mvn test -B'"

      _run_command(cmd, {:out => out_log, :err => err_log})
    end


    def _copy_junit_reports_to_handout_automarker_dir(handout_id)
      src_dir = File.join(_automarker_repo_root, 'target', 'surefire-reports')
      dst_dir = handout_automarker_dir(handout_id)
      FileUtils.cp_r(src_dir, dst_dir) if Dir.exists? src_dir
    end

    #
    # Opts:
    # - chdir, String, run the command from this directory
    # - out, Writable Stream
    # - err, Writable Stream
    #
    def _run_command(cmd, opts = {})
      env = {}

      t1 = Time.now
      puts "Running command:\n#{cmd}"
      result = system(env, cmd, opts)
      t2 = Time.now
      puts "Ran command in #{t2 - t1} seconds (Ruby's system call returned #{result})"
    end

    #---------------------------------------------------------------------------

    def handout_junit_reports_dir(handout_id)
      File.join(handout_automarker_dir(handout_id), 'surefire-reports')
    end


    def count_failures_and_errors_in_junit_reports(xml_reports)
      failures,errors = 0, 0

      xml_reports.each do |path_to_xml_report|
        f = File.open(path_to_xml_report)
        report = Nokogiri::XML(f)
        f.close

        failures += report.xpath('testsuite').first.attr('failures').to_i
        errors   += report.xpath('testsuite').first.attr('errors').to_i
      end

      return failures, errors
    end


    def _automarker_repo_name
      "#{GitHubClassroom::sandbox_repo_name(conf.assignment)}-automarker"
    end

    def _automarker_repo_root
      File.join(work_dir,  _automarker_repo_name)
    end

    def _automarker_repo_exists?
      Dir.exists? _automarker_repo_root
    end


    def _create_automarker_repo()
      puts "Creating automarker repo at #{_automarker_repo_root} ..."

      # Clone the sanxbox repo (containing the full test suite is)
      client = GitHubClassroom::ScriptUtil.create_default_client(conf)
      client.clone(GitHubClassroom::sandbox_repo_name(conf.assignment), _automarker_repo_root)
      client.ungitify_local_repo(_automarker_repo_root)  # Remove the .git folder (to prevent someone from accidently pushing changes from this repo back to GitHub)

      # Remove the application code (but not the tests)
      ['java', 'resources'].each do |folder_name|
        folder = File.join(_automarker_repo_root, 'src', 'main', folder_name)
        Dir.foreach(folder) do |entry|
          FileUtils.rm_rf(File.join(folder, entry)) unless ['.', '..', '.gitkeep'].include? entry
        end
      end

      # Add the application code (i.e. the part of the code that we just deleted)
      # as a Maven dependency
      _update_automarker_pom(File.join(_automarker_repo_root, 'pom.xml'))

    end


    def _update_automarker_pom(path_to_pom_file)
      f = File.open(path_to_pom_file)
      pom = Nokogiri::XML(f)
      f.close

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
      pom.write_xml_to(f)  # TODO: Do we need to specify encoding?
      f.close
    end


  end
end
