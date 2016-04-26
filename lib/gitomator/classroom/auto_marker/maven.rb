require 'gitomator/classroom/auto_marker/dockerized'
require 'fileutils'
require 'nokogiri'


module Gitomator
  module Classroom
    module AutoMarker
      class Maven < Gitomator::Classroom::AutoMarker::Dockerized


        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker]
        # @param work_dir [String] Path to an existing directory
        #
        def initialize(context, auto_marker_config, work_dir)
          super(context, auto_marker_config, work_dir)

          before_auto_marking do
            logger.debug "TODO: Create/clone auto-marker repo in #{work_dir}"
            logger.debug "TODO: Fetch auto-marker's docker image"
          end

          # TODO: This is here an an example ...
          after_auto_marking do |repo2mark, repo2error|
            logger.info "#{repo2mark.length} repo(s) marked successfully, #{repo2error.length} error(s)."
            logger.debug "Marks: #{repo2mark}"
            logger.debug "Errors: #{repo2error}"
          end
        end


        def create_resources_dir(repo)
          super(repo)
          FileUtils.cp_r(File.join(work_dir, 'automarker'),
                         File.join(resources_dir(repo), 'automarker'))
        end


        def docker_image
          return 'joeyfreund/automarker-intro-fall-2015'
        end


        def auto_mark(repo)
          super(repo)
          reports = Dir[File.join(junit_reports_dir(repo), '*.xml')]
          logger.debug "Found #{reports.length} JUnit XML reports."
          return reports.map {|path| [path, parse_junit_xml_report(path)] }.to_h
        end


        def parse_junit_xml_report(path_to_xml)
          f = File.open(path_to_xml)
          xml = Nokogiri::XML(f)
          f.close

          testcase2status = {}

          xml.xpath('testsuite/testcase').each do |tc|
            name = tc.attr('name')
            if tc.xpath('failure').length > 0
              testcase2status[name] = :fail
            elsif tc.xpath('error').length > 0
              testcase2status[name] = :error
            else
              testcase2status[name] = :pass
            end
          end

          return testcase2status
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


        def junit_reports_dir(repo)
          return File.join(results_dir(repo), 'surefire-reports')
        end


      end
    end
  end
end
