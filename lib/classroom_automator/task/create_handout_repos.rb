require 'classroom_automator/task/assignment_base'

module ClassroomAutomator
  module Task
    class CreateHandoutRepos < ClassroomAutomator::Task::AssignmentBase


      def initialize(context, assignment_config)
        super(context, assignment_config, nil)
      end


      def run
        logger.info "About to create #{handouts.length} handout repo(s) ..."
        super()
        logger.info "Done."
      end


      def process_handout(repo_name, i)
        super
        if (hosting.read_repo(repo_name).nil?)
          hosting.create_repo(repo_name)
        else
          logger.info "Skipping #{repo_name}, repo already exists."
        end
      end



    end
  end
end
