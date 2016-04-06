require 'classroom_automator'

require 'gitomator/service/git/service'
require 'gitomator/service/git/provider/shell'

require 'gitomator/service/hosting/service'

require 'gitomator/service/ci/service'



module ClassroomAutomator


  #
  # A context containing all the Gitomator services needed by an application.
  # See `spec/data/context.yml` for an example of a configuration file.
  #
  # Note: The context lazy-loads services (i.e. it will load the provider
  # library and create the service provider, when you first access a service).
  #
  class Context

    #=========================================================================

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


    attr_reader :conf

    def initialize(conf = {})
      @conf = conf
    end


    #=========================================================================
    # Lazy-loading attribute readers


    def logger
      gem 'logger'; require 'logger'
      @logger ||= _create_logger
    end

    def git
      @git ||= Gitomator::Service::Git::Service.new (
        Gitomator::Service::Git::Provider::Shell.new )
    end

    def hosting
      @hosting ||= _create_hosting_service
    end

    def ci
      @ci ||= _create_ci_service
    end


    #=========================================================================
    # Private helper methods


    def _create_hosting_service()
      c = conf['hosting']

      if c.nil?
        require "gitomator/service/hosting/provider/local"
        return Gitomator::Service::Hosting::Service.new (
          Gitomator::Service::Hosting::Provider::Local.new(
            git, Dir.mktmpdir('classroom_automator_')
          )
        )

      elsif c['provider'] == 'local'
        require "gitomator/service/hosting/provider/local"
        return Gitomator::Service::Hosting::Service.new (
          Gitomator::Service::Hosting::Provider::Local.new(
            git, c['dir']
          )
        )

      elsif c['provider'] == 'github'
        require 'gitomator/github/hosting_provider'
        return Gitomator::Service::Hosting::Service.new (
          Gitomator::GitHub::HostingProvider.with_access_token(
            c['access_token'], {org: c['organization']}
          )
        )

      else
        raise "Invalid hosting service configuration - #{c}"
      end
    end



    def _create_ci_service()
      c = conf['ci']

      if c.nil?
        raise "Cannot create CI service - Missing configuration."

      elsif c['provider'] == 'travis_pro'
        require 'gitomator/travis/ci_provider'
        return Gitomator::Service::CI::Service.new(
          Gitomator::Travis::CIProvider.with_travis_pro_access_token(
            c['access_token'], c['github_organization']
          )
        )

      elsif c['provider'] == 'travis'
        require 'gitomator/travis/ci_provider'
        return Gitomator::Service::CI::Service.new(
          Gitomator::Travis::CIProvider.with_travis_access_token(
            c['access_token'], c['github_organization']
          )
        )

      else
        raise "Cannot create CI service - Invalid configuration, #{c}."
      end
    end


    def _create_logger()
      c = conf['logger']

      if c.nil?
        return Logger.new(STDOUT)
      end

      output = STDOUT
      case c['output']
      when nil
        output = STDOUT
      when 'STDOUT'
        output = STDOUT
      when 'STDERR'
        output = STDERR
      when 'NULL' || 'OFF'        # Write the dev/null (i.e. logging is off)
        output = File.open(File::NULL, "w")
      else
        output = File.open(c['output'], "a")
      end

      lgr = Logger.new(output)
      if c['level']
        lgr.level = Logger.const_get(c['level'])
      end
      return lgr
    end


  end
end
