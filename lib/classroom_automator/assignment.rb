require 'classroom_automator'

module ClassroomAutomator


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
    attr_reader :repos


    def parse_config(config)
      # Create an attr_accessor for each configuration attribute ...
      config.each do |key, value|
        setter = "#{key}="
        self.class.send(:attr_accessor, key) if !respond_to?(setter)
        send setter, value
      end

      # Transform the repos configuration info (we support multiple formats)
      # into a hash that maps repo-names to lists of students-usernames.
      @repos = parse_repos_config(repos)
    end

    def method_missing(method_sym, *arguments, &block)
      return nil
    end


    def parse_repos_config(repos_conf)
      if( repos_conf.nil?)
        return {}
      end

      result = {}

      repos_conf.each do |repo_config|
        repo, students = parse_repo_config(repo_config)
        raise DuplicateRepoError.new(repo) if result.has_key? repo
        result[repo] = students
      end

      return result
    end


    #
    # Extract the repo-name and usernames from a single entry in the
    # `repos` section of the configuration.
    #
    # @param repo_config [String or Hash]
    #
    # @return [String, String array] Return the pair <repo-name, usernames>.
    #
    def parse_repo_config(repo_config)
      if repo_config.is_a? String
        return repo_config, []
      elsif (repo_config.is_a? Hash) and (repo_config.length == 1)
        usernames = repo_config.values.first
        usernames = [ usernames.to_s ] unless usernames.is_a? Array
        return repo_config.keys.first.to_s, usernames.map {|u| u.to_s}
      else
        raise "Invalid repo config item: #{repo_config}"
      end
    end


  end


end
