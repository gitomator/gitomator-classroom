require 'gitomator/classroom'

require 'gitomator/context'
require 'gitomator/service/hosting/service'
require 'gitomator/service/tagging/service'
require 'gitomator/service/ci/service'



module Gitomator
  module Classroom
    class Context < Gitomator::Context


      def initialize(config)
        super(config)

        register_service_factory :hosting do |hosting_config|
          create_hosting_service(hosting_config || {})
        end

        register_service_factory :ci do |ci_config|
          create_ci_service(ci_config || {})
        end

        register_service_factory :tagging do |tagging_config|
          create_tagging_service(tagging_config || {})
        end

      end


      def tagging
        @tagging ||= create_service(:tagging)
      end



      def create_hosting_service(config)
        case config['provider']
        when nil
          return create_default_hosting_service(config)
        when 'local'
          return create_default_hosting_service(config)
        when 'github'
          require 'gitomator/github/hosting_provider'
          return Gitomator::Service::Hosting::Service.new (
            Gitomator::GitHub::HostingProvider.from_config(config))
        else
          raise "Invalid hosting provider in service configuration - #{config}"
        end
      end


      def create_ci_service(config)
        if ['travis', 'travis_pro'].include? config['provider']
          require 'gitomator/travis/ci_provider'
          return Gitomator::Service::CI::Service.new(
            Gitomator::Travis::CIProvider.from_config(config))
        else
          raise "Cannot create CI service - Invalid configuration, #{config}."
        end
      end


      def create_tagging_service(config)
        if config['provider'] == 'github'
          require 'gitomator/github/tagging_provider'
          return Gitomator::Service::Tagging::Service.new (
            Gitomator::GitHub::TaggingProvider.from_config(config))
        else
          raise "Invalid hosting provider in service configuration - #{config}"
        end
      end


    end
  end
end
