require 'classroom_automator/workflow/task/assignment_base'

module ClassroomAutomator
  module Workflow
    module Task

      #
      # Common module to be included in both EnableCI and DisableCI classes
      #
      module EnableDisableCI

        def initialize(context, assignment_config)
          super(context, assignment_config, nil)
        end

        def run
          sync
          super()
          logger.info "Done."
        end

        def sync
          logger.info "Syncing CI ..."
          ci.sync
          while ci.syncing?
            print "."
            sleep 1
          end
          logger.info "CI synchronized"
        end

      end



      class EnableCI < ClassroomAutomator::Workflow::Task::AssignmentBase
        include EnableDisableCI

        def process_handout(repo_name, i)
          logger.info "Enabling CI for #{repo_name} (#{i + 1} out of #{handouts.length})"
          ci.enable_ci repo_name
        end

      end


      class DisableCI < ClassroomAutomator::Workflow::Task::AssignmentBase
        include EnableDisableCI

        def process_handout(repo_name, i)
          logger.info "Disabling CI for #{repo_name} (#{i + 1} out of #{handouts.length})"
          ci.disable_ci repo_name
        end

      end


    end
  end
end
