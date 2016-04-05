require 'classroom_automator'

module ClassroomAutomator
  module Config

    class DuplicateRepoError < StandardError
      def initialize(repo_name)
        super("Invalid config - duplicate repo, #{repo_name}.")
      end
    end


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
        return from_hash(ClassroomAutomator::Util.load_config(conf_file))
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


      # A hash mapping repo-name (String) to student usernames (String array).
      attr_reader :handouts


      def parse_config(config)
        # Create an attr_accessor for each configuration attribute ...
        config.each do |key, value|
          setter = "#{key}="
          self.class.send(:attr_accessor, key) if !respond_to?(setter)
          send setter, value
        end

        # Transform the handouts configuration info (we support multiple formats)
        # into a hash that maps repo-names to lists of students-usernames.
        @handouts = parse_handouts_config(handouts)
      end


      def parse_handouts_config(handouts_conf)
        if( handouts_conf.nil?)
          return {}
        end

        result = {}

        handouts_conf.each do |handout_conf|
          repo, students = parse_handout_config(handout_conf)
          raise DuplicateRepoError.new(repo) if result.has_key? repo
          result[repo] = students
        end

        return result
      end


      #
      # Extract the repo-name and usernames from a single entry in the
      # `handouts` section of the configuration.
      #
      # @param handout_conf [String or Hash]
      #
      # @return [String, String array] Return the pair <repo-name, usernames>.
      #
      def parse_handout_config(handout_conf)
        if handout_conf.is_a? String
          return handout_conf, []
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
