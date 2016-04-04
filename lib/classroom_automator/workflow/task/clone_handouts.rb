require 'classroom_automator/workflow/task/assignment_base'

module ClassroomAutomator
  module Workflow
    module Task
      class CloneHandouts < ClassroomAutomator::Workflow::Task::AssignmentBase


        def initialize(context, assignment_config, local_dir)
          raise "No such folder, #{local_dir}." unless Dir.exists? local_dir
          super(context, assignment_config, local_dir)
        end
        

        def handouts
          assignment_config.handouts
        end


        def run
          logger.info("About to clone #{handouts.length} handout(s) ...")

          i = 0
          handouts.each do |repo_name, students|
            begin
              i += 1
              process_handout(repo_name, i)
            rescue => e
              backtrace = e.backtrace.join("\n\t")
              logger.error("Error in handout #{handout_id}.\n#{backtrace}")
            end
          end

          logger.info("Done.")
        end



        def process_handout(repo_name, index)
          logger.info "Clonning #{repo_name} (#{index} out of #{handouts.length})"

          local_repo_root = File.join(local_dir, repo_name)
          repo = hosting.read_repo(repo_name)

          if repo.nil?
            logger.warn("Skipping #{repo_name} (handout repo doesn't exist)")
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
