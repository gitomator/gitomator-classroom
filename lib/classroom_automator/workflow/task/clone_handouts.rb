require 'classroom_automator/workflow/task/assignment_base'

module ClassroomAutomator
  module Workflow
    module Task
      class CloneHandouts < ClassroomAutomator::Workflow::Task::AssignmentBase


        alias_method :assignment, :assignment_config


        def run
          logger.info("About to clone #{assignment.handouts.length} handout(s).")

          i = 0
          assignment.handouts.each do |handout_id, students|
            begin
              i += 1
              process_handout(handout_id, i)
            rescue => e
              backtrace = e.backtrace.join("\n\t")
              logger.error("Error in handout #{handout_id}.\n#{backtrace}")
            end
          end

          logger.info("Done.")
        end



        def process_handout(handout_id, index)
          logger.info "Handout #{handout_id} (#{index} out of #{assignment.handouts.length})"

          repo_name = "assignment-#{assignment.assignment}-handout-#{handout_id}"
          local_repo_root = File.join(local_dir, repo_name)
          repo = hosting.read_repo(repo_name)

          if repo.nil?
            logger.warn("Skipping #{handout_id} (handout repo doesn't exist)")
          elsif Dir.exist? local_repo_root
            logger.info("Local repo already exists, '#{local_repo_root}'.")
          else
            git.clone(repo.url, local_repo_root)
          end
        end

      end
    end
  end
end
