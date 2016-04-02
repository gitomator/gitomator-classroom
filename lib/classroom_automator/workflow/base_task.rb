module ClassroomAutomator
  module Workflow
    class BaseTask


      attr_reader :hosting, :git, :ci, :logger

      #
      # @param opts [Hash]
      # => @param :hosting [Gitomator::Service::Hosting::Service]
      # => @param :git [Gitomator::Service::Git::Service]
      # => @param :ci [Gitomator::Service::CI::Service]
      # => @param :logger [Logger]
      #
      def initialize(opts = {})
        @opts = opts
        @logger  = opts[:logger] || Logger.new(STDOUT)
      end

      # Service attr_readers are lazy-loading ...

      def hosting
        @opts[:hosting]
      end

      def git
        @opts[:git]
      end

      def ci
        @opts[:ci]
      end


      def run()
        raise "Subclasses must implement the run() method"
      end


    end
  end
end
