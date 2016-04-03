require 'classroom_automator/config/util'

gem 'logger'; require 'logger'

require 'gitomator/service/git/service'
require 'gitomator/service/git/provider/shell'

require 'gitomator/service/hosting/service'
require 'gitomator/github/hosting_provider'

require 'gitomator/service/ci/service'
require 'gitomator/travis/ci_provider'


module ClassroomAutomator
  module Workflow
    class DefaultTaskOpts

      #=========================================================================
      # Static factory methods

      class << self
        private :new
      end

      #
      # See `spec/data/task_conf` for an example configuration file
      #
      # @param conf_file [String/File] - Path to a YAML configuration file.
      #
      def self.from_file(conf_file)
        from_hash(ClassroomAutomator::Config::Util.conf_file_to_hash(conf_file))
      end

      #
      # @param conf [Hash] - Configuration data (e.g. parsed from a YAML file)
      #
      def self.from_hash(conf)
        new(conf)
      end


      #=========================================================================


      attr_reader :hosting, :git, :ci, :logger

      #
      # @param conf [Hash] - Configuration data (e.g. loaded from YAML file)
      #
      def initialize(conf)
        @conf = conf
      end


      def [](key)
        return self.send(key)
      end

      def []=(key, value)
        setter = "#{key}="
        self.class.send(:attr_accessor, key) if !respond_to?(setter)
        send setter, value
      end


      def to_s
        return "#<#{self.class}>"
      end

      def inspect
        return to_s
      end


      # Lazy getters ...

      def logger
        if @logger.nil?

          log_device = STDOUT  # Default
          if @conf.has_key? 'LOGGER_OUTPUT'
            case @conf['LOGGER_OUTPUT']
            when 'STDOUT'
              log_device = STDOUT
            when 'STDERR'
              log_device = STDERR
            when 'NULL'
              log_device = File.open(File::NULL, "w")
            else
              log_device = File.open(@conf['LOGGER_OUTPUT'], "a")
            end
          end

          @logger = Logger.new(log_device)

          if @conf.has_key? 'LOGGER_LEVEL'
            case @conf['LOGGER_LEVEL']
            when 'DEBUG'
              @logger.level = Logger::DEBUG
            when 'INFO'
              @logger.level = Logger::INFO
            when 'WARN'
              @logger.level = Logger::WARN
            when 'ERROR'
              @logger.level = Logger::ERROR
            end
          end
        end

        return @logger
      end



      def git
        if (@git.nil?)
          @git = Gitomator::Service::Git::Service.new (
            Gitomator::Service::Git::Provider::Shell.new )
        end
        return @git
      end



      def hosting
        if (@hosting.nil?)
          @hosting = Gitomator::Service::Hosting::Service.new (
            Gitomator::GitHub::HostingProvider.with_access_token(
              @conf['GITHUB_ACCESS_TOKEN'], {org: @conf['GITHUB_ORGANIZATION']}
            )
          )
        end
        return @hosting
      end



      def ci
        if (@ci.nil?)
          provider = nil
          if (@conf['WITH_TRAVIS_PRO'])
            provider = Gitomator::Travis::CIProvider.with_travis_pro_access_token(
              @conf['TRAVIS_ACCESS_TOKEN'], @conf['GITHUB_ORGANIZATION']
            )
          else
            provider = Gitomator::Travis::CIProvider.with_travis_access_token(
              @conf['TRAVIS_ACCESS_TOKEN'], @conf['GITHUB_ORGANIZATION']
            )
          end

          @ci = Gitomator::Service::CI::Service.new (provider)
        end
        return @ci
      end



    end
  end
end
