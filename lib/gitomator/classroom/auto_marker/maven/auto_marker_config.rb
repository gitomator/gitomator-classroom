require 'gitomator/classroom/config/auto_marker'


module Gitomator
  module Classroom
    module AutoMarker
      module Maven


        class AutoMarkerConfig < Gitomator::Classroom::Config::AutoMarker

          attr_accessor :auto_marker_source_repo

          def initialize(config_obj)
            super(config_obj)
            @docker_image ||= 'maven:3-jdk-8'

            @auto_marker_source_repo = config_obj['auto_marker_source_repo']
            @auto_marker_source_repo ||= source_repo
          end

        end

      end
    end
  end
end
