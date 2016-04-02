require 'yaml'
require 'erb'

module ClassroomAutomator
  module Config
    class Assignment


      #=========================================================================
      # Static factory methods

      class << self
        private :new
      end

      #
      # @param conf_file [String] - Path to a YAML configuration file.
      #
      def self.from_file(conf_file)
        return from_hash(YAML::load(ERB.new(File.read(conf_file)).result))
      end

      #
      # @param conf_data [Hash] - Configuration data (e.g. parsed from a YAML file)
      #
      def self.from_hash(conf_data)
        return new(conf_data)
      end


      #=========================================================================


      #
      # @param conf_data [Hash] Configuration data (e.g. parsed from a YAML file)
      #
      def initialize(conf_data)
        parse_config(conf_data)
      end


      # A hash mapping handout-id (String) to student GitHub usernames (Array of Strings)
      attr_reader :handouts


      def parse_config(config)
        # Create an attr_accessor for each configuration attribute ...
        config.each do |key, value|
          setter = "#{key}="
          self.class.send(:attr_accessor, key) if !respond_to?(setter)
          send setter, value
        end

        # Transform the handouts configuration info (we support multiple formats)
        # into a hash that maps handout-id's to lists of students-usernames.
        @handouts = parse_handouts_config(handouts)
      end


      def parse_handouts_config(handouts_conf)
        if( handouts_conf.nil?)
          return {}
        end

        result = {}

        handouts_conf.each do |handout_conf|
          handout_id, students = parse_handout_config(handout_conf)
          raise "Invalid config - Repeated handout-id, '#{handout_id}'." if result.has_key? handout_id
          result[handout_id] = students
        end

        return result
      end


      #
      # Extract the handout-id and list of usernames from a single entry in
      # the `handouts` section of the configuration.
      #
      # If handout_conf is a String, this method assumes that the string is a GitHub username,
      # and uses the username as a handout-id as a default.
      #
      # Otherwise, handout_conf is expected to be a hash with a single entry,
      # mapping a handout-id to GitHub username(s).
      #
      # @return [String,Array of strings] Return the pair <handout-id, github-usernames>.
      def parse_handout_config(handout_conf)
        if handout_conf.is_a? String
          return handout_conf, [ handout_conf ]
        elsif (handout_conf.is_a? Hash) and (handout_conf.length == 1)
          usernames = handout_conf.values.first
          usernames = [ usernames.to_s ] unless usernames.is_a? Array
          return handout_conf.keys.first.to_s, usernames.map {|u| u.to_s}
        else
          raise "Invalid handout config item: #{handout_conf}"
        end
      end



    end

  end
end
