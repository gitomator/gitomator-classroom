require 'gitomator/classroom'

module Gitomator
  module Classroom
    module Config
      class Base


        #=======================================================================
        # Static factory methods

        class << self
          private :new
        end

        #
        # @param conf_file [String] - Path to an ERB/YAML configuration file.
        #
        def self.from_file(conf_file)
          return from_hash(Gitomator::Classroom::Util.load_config(conf_file))
        end

        #
        # @param conf_data [Hash] - Configuration data (e.g. parsed from a YAML file)
        #
        def self.from_hash(conf_data)
          return new(conf_data)
        end


        #=======================================================================
        # Some Ruby "magic" to generate property-getters (aka attr_readers)
        # dynamically, and do some config validation in the constructor.
        # See auto_marker.rb as an example.




        def self.property(name, opts={})
          @prop_name_2_opts ||= {}
          @prop_name_2_opts[name] = opts
          # Dynamically create the attr_reader (i.e. property getter)
          self.send(:define_method, name) do
            config[name.to_s] || opts[:default]
          end
        end


        def self.validate_config(config)
          @prop_name_2_opts ||= {}
          @prop_name_2_opts.each do |name, opts|
            value = config[name.to_s]

            if opts[:required] && value.nil?
              raise Gitomator::Classroom::Exception::InvalidConfig.new("Missing property, #{name}")
            end

            if opts[:is_dir] && (! Dir.exist?(value))
              raise Gitomator::Classroom::Exception::InvalidConfig.new("No such directory, #{value}")
            end

            if opts[:is_file] && (! File.exist?(value))
              raise Gitomator::Classroom::Exception::InvalidConfig.new("No such file, #{value}")
            end

            if opts[:is_executable] && (! File.executable?(value))
              raise Gitomator::Classroom::Exception::InvalidConfig.new("Not an executable, #{value}")
            end

          end
        end

        #=======================================================================


        attr_reader :config

        #
        # @param config [Hash<String,Object>] Configuration data
        #
        def initialize(config)
          @config = config.map {|k,v| [k.to_s,v]} .to_h
          self.class.validate_config(@config)
        end


      end
    end
  end
end
