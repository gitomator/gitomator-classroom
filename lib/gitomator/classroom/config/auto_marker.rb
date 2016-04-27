require 'gitomator/classroom/config/assignment'

module Gitomator
  module Classroom
    module Config
      class AutoMarker < Gitomator::Classroom::Config::Assignment

        property :docker_image, {:required => true}
        property :automarker_script, {:required => true, :is_executable => true }
        property :results_dir, {:required => true, :is_dir => true}
        property :resources, {:default => []}

      end
    end
  end
end
