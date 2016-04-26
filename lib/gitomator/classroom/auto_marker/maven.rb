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

          # TODO: This is here an an example ...
          after_auto_marking do |repo2mark, repo2error|
            logger.info "#{repo2mark.length} repo(s) marked successfully, #{repo2error.length} error(s)."
            logger.debug "Marks: #{repo2mark}"
            logger.debug "Errors: #{repo2error}"
          end
        end


        def auto_mark(repo)
          super(repo)
          return Dir[File.join(results_dir(repo), 'surefire-reports', '*.xml')]
                  .map {|path| [path, parse_junit_xml_report(path)] }.to_h
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



      end
    end
  end
end
