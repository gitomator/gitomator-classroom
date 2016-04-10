require 'trollop'
require 'classroom_automator/version'


module ClassroomAutomator
  module ScriptUtil

    DEFAULT_CONTEXT_ENV_VAR_NAME = 'CLASSROOM_AUTOMATOR_CONTEXT'

    def self.default_context_file
      ENV[DEFAULT_CONTEXT_ENV_VAR_NAME]
    end

    #---------------------------------------------------------------------------

    class DefaultOptionParser < Trollop::Parser

      def initialize(usage_message)
        super()
        banner "Classroom Automator #{ClassroomAutomator::VERSION}.\n\nOptions:"
        version "#{ClassroomAutomator::VERSION}"
        usage   usage_message

        opt :context,
              "Context (logger, hosting, git, ci) configuration file (uses #{DEFAULT_CONTEXT_ENV_VAR_NAME} env variable, by default). " ,
              :default => ScriptUtil::default_context_file,
              :type => :string
      end

      def parse(args)
        return { :context => ScriptUtil::default_context_file }.merge(
          Trollop::with_standard_exception_handling(self) { super(args)  }
        )
      end

    end

    #---------------------------------------------------------------------------

    #
    # @param task [Gitomator::Task::*] An object with a run() method.
    #
    def self.run_task(task)
      begin
        task.run
      rescue => e
        abort "ERROR: #{e}.\n\n#{e.backtrace.join("\n\t")}"
      end
    end

    #
    # @param tasks [Array<Gitomator::Task::*>]
    #
    def self.run_tasks(tasks)
      begin
        tasks.each { |task| task.run }
      rescue => e
        abort "ERROR: #{e}.\n\n#{e.backtrace.join("\n\t")}"
      end
    end

    #
    # @return [ClassroomAutomator::Context]
    #
    def self.context_from_file(config_file)
      require 'classroom_automator/context'
      ClassroomAutomator::Context.from_file(config_file)
    end

    #
    # @return [ClassroomAutomator::Assignment]
    #
    def self.assignment_config_from_file(config_file)
      require 'classroom_automator/assignment'
      ClassroomAutomator::Assignment.from_file(config_file)
    end

    #
    # @return [Hash<String,ClassroomAutomator::Team>]
    #
    def self.teams_from_file(config_file)
      require 'classroom_automator/team'
      ClassroomAutomator::Team.teams_from_file(config_file)
    end

    #---------------------------------------------------------------------------


  end
end
