
module ClassroomAutomator
  module Workflow
    module Task
      class Base

        attr_reader :context

        #
        # @param context [ClassroomAutomator::Context]
        #
        def initialize(context)
          @context = context
        end


        def logger
          context.logger
        end

        def git
          context.git
        end

        def hosting
          context.hosting
        end

        def ci
          context.ci
        end



        def run
          raise "Unimplemented"
        end

      end
    end
  end
end
