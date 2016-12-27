require 'gitomator/task/base_repos_task'
require 'fileutils'
require 'nokogiri'

module Gitomator
  module Classroom
    module AutoMarker
      module Maven


        class ResultsCollector < Gitomator::Task::BaseReposTask


          #
          # @param context [Gitomator::Context]
          # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker]
          # @param local_dir [String] A local directory where the repos will be (or have been) cloned.
          #
          def initialize(context, auto_marker_config, local_dir)
            super(context, auto_marker_config.repos, local_dir)
          end


          #
          # @return [Hash<String,Array<Int>>] Map XML filename to an array with two ints (the number of failures and errors, resp, in the file)
          #
          def process_repo(repo, index)
            reports_dir = File.join(local_dir, repo, 'surefire-reports')
            Dir.glob("#{reports_dir}/**/*.xml")
              .map { |p| [File.basename(p), count_failures_and_errors_in_junit_report(p)]}
              .to_h
          end


          def count_failures_and_errors_in_junit_report(path_to_xml)
            f = File.open(path_to_xml)
            xml_doc = Nokogiri::XML(f)
            f.close

            return xml_doc.xpath('testsuite').first.attr('failures').to_i,
                   xml_doc.xpath('testsuite').first.attr('errors').to_i
          end

        end


      end
    end
  end
end
