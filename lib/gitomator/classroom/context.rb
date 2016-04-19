require 'gitomator/classroom'
require 'gitomator/context'


module Gitomator
  module Classroom
    class Context < Gitomator::Context


      def create_github_hosting_service(config)
        require 'gitomator/service/hosting'
        require 'gitomator/github/hosting_provider'
        return Gitomator::Service::Hosting.new (
          Gitomator::GitHub::HostingProvider.from_config(config))
      end


      def create_travis_ci_service(config)
        require 'gitomator/service/ci'
        require 'gitomator/travis/ci_provider'
        return Gitomator::Service::CI.new(
          Gitomator::Travis::CIProvider.from_config(config))
      end

      def create_travis_pro_ci_service(config)
        create_travis_ci_service(config)
      end


      def create_github_tagging_service(config)
        require 'gitomator/service/tagging'
        require 'gitomator/github/tagging_provider'
        return Gitomator::Service::Tagging.new (
          Gitomator::GitHub::TaggingProvider.from_config(config))
      end


    end
  end
end
