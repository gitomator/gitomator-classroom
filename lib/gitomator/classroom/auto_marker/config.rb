require 'gitomator/task/config/repos_config'


module Gitomator
  module Classroom
    module AutoMarker
      class Config < Gitomator::Task::Config::ReposConfig


        attr_accessor :docker_image
        attr_accessor :automarker_script
        attr_accessor :resources
        attr_accessor :env


        #
        # @param config_obj [Hash] Configuration data (commonly loaded from a YAML file)
        #
        def initialize(config_obj)
          super(config_obj)

          @docker_image      = config_obj['docker_image']
          @automarker_script = File.expand_path config_obj['automarker_script']
          @resources         = (config_obj['resources'] || {})
          @resources = @resources.map {|r,p| [r, File.expand_path(p)]} .to_h

          @env               = config_obj['env'] || {}
        end


        def validate()
          raise "Missing docker_image" if docker_image.nil?
          raise "Missing automarker_script" if automarker_script.nil?

          required(automarker_script)
          unless File.executable? automarker_script
            raise "Not executable #{automarker_script} "
          end

          resources.each do |_, path|
            required(path)
          end
        end

        def required(path)
          unless File.exist?(File.expand_path(path))
            raise "No such file/directory #{path} "
          end
        end

      end
    end
  end
end
