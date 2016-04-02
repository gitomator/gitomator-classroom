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
        @hosting = opts[:hosting]
        @git     = opts[:git]
        @ci      = opts[:ci]
        @logger  = opts[:logger] || Logger.new(STDOUT)
      end


      def run()
        raise "Subclasses must implement the run() method"
      end


    end
  end
end
