require 'trollop'
require 'classroom_automator/version'
require 'classroom_automator/context'
require 'classroom_automator/assignment'


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
              "Context (logger, hosting, git, ci) configuration file. ",
              :default =>  ScriptUtil::default_context_file || "#{DEFAULT_CONTEXT_ENV_VAR_NAME} env variable, currently not set.",
              :type => :string
      end

      def parse(args)
        return { :context => ScriptUtil::default_context_file }.merge(
          Trollop::with_standard_exception_handling(self) { super(args)  }
        )
      end

    end

    #---------------------------------------------------------------------------


    def self.run_task(task)
      begin
        task.run
      rescue => e
        abort "ERROR: #{e}.\n\n#{e.backtrace.join("\n\t")}"
      end
    end


    def self.task_with_context_config_assignment_config_and_local_dir(
      task_class, context_conf_file, assignment_conf_file, local_dir)

      task_class.new(
        ClassroomAutomator::Context.from_file(context_conf_file),
        ClassroomAutomator::Assignment.from_file(assignment_conf_file),
        local_dir
      )
    end

    def self.task_with_context_config_and_assignment_config(
      task_class, context_conf_file, assignment_conf_file)

      task_class.new(
        ClassroomAutomator::Context.from_file(context_conf_file),
        ClassroomAutomator::Assignment.from_file(assignment_conf_file)
      )
    end


    #---------------------------------------------------------------------------


  end
end
