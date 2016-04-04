require "classroom_automator/version"

module ClassroomAutomator
  module Util
    module CommandLine

      require "trollop"

      def self.parse_opts(usage_message='Command-line options:')
        opts = Trollop::options do
          version ClassroomAutomator::VERSION
          banner usage_message
          opt :context,
                "Context configuration file (default: ENV['CLASSROOM_AUTOMATOR_CONTEXT'])",
                :type => :string
        end

        opts[:context] = opts[:context] || ENV['CLASSROOM_AUTOMATOR_CONTEXT']
        return opts
      end

    end
  end
end
