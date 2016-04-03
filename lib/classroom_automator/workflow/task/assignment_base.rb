require 'classroom_automator/workflow/task/base'

module ClassroomAutomator
  module Workflow
    module Task
      class AssignmentBase < ClassroomAutomator::Workflow::Task::Base

        attr_reader :assignment_config, :local_dir

        #
        # @param context [ClassroomAutomator::Workflow::Context]
        # @param assignment_config [ClassroomAutomator::Config::Assignment]
        # @param local_dir [String]
        #
        def initialize(context, assignment_config, local_dir)
          super(context)
          @assignment_config = assignment_config
          @local_dir = local_dir
        end


        def run
          raise "Unimplemented"
        end

      end
    end
  end
end
