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


        def handouts
          assignment_config.handouts
        end


        def run
          handouts.keys.each_with_index do |repo_name, index|
            begin
              process_handout(repo_name, index)
            rescue => e
              on_process_handout_error(repo_name, index, e)
            end
          end
        end


        def process_handout(repo_name, index)
          # Override this method in subclasses
        end

        def on_process_handout_error(repo_name, index, error)
          # Override this method in subclasses
        end


      end
    end
  end
end
