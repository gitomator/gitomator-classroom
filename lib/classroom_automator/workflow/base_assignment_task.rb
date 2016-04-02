require 'classroom_automator/workflow/base_task'


module ClassroomAutomator
  module Workflow
    class BaseAssignmentTask < ClassroomAutomator::Workflow::BaseTask


      #
      # @param assignment_conf [ClassroomAutomator::Config::Assignment]
      # @param task_conf [Hash]
      #
      def initialize(assignment_conf, task_conf)
        super(task_conf)
        @assignment_conf = assignment_conf
      end

      #-------------------------------------------------------------------------

      def pre_processing()
        logger.debug("Start task ...")
      end

      #
      # @param handout_id [String]
      # @param students [Array[String]]
      # @param index [Integer] - One-based index
      #
      def process_handout(handout_id, students, index)
        logger.info("Processing handout #{handout_id}, for students #{students}. (#{index} out of #{@assignment_conf.handouts.length})")
      end

      #
      # @param handout_id [String]
      # @param error [StandardError]
      #
      def on_process_handout_error(handout_id, error)
        logger.error("Error while processing handout #{handout_id} - #{error}.\n#{error.backtrace.join("\n\t")}")
      end


      def post_processing()
        logger.debug("Finished task")
      end

      #-------------------------------------------------------------------------

      def run()
        pre_processing()

        i = 0
        @assignment_conf.handouts.each do |handout_id, students|
          begin
            i += 1
            process_handout(handout_id, students, i)
          rescue => e
            on_process_handout_error(handout_id, e)
          end
        end

        post_processing()
      end

      #-------------------------------------------------------------------------

    end
  end
end
