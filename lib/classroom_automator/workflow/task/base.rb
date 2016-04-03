
module ClassroomAutomator
  module Workflow
    module Task
      class Base

        attr_reader :context

        #
        # @param context [ClassroomAutomator::Workflow::Context]
        #
        def initialize(context)
          @context = context
        end

        def run
          raise "Unimplemented"
        end

      end
    end
  end
end
