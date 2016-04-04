require 'classroom_automator/workflow/task/assignment_base'

module ClassroomAutomator
  module Workflow
    module Task
      class CloneHandouts < ClassroomAutomator::Workflow::Task::AssignmentBase


        def initialize(context, assignment_config, local_dir)
          raise "No such folder, #{local_dir}." unless Dir.exists? local_dir
          super(context, assignment_config, local_dir)
        end



        def process_handout(repo_name, i)
          logger.debug "#{repo_name} (#{i + 1} out of #{handouts.length})"

          local_repo_root = File.join(local_dir, repo_name)
          if Dir.exist? local_repo_root
            logger.info "Local repo already exists, '#{local_repo_root}'."
            return
          end

          repo = hosting.read_repo(repo_name)
          if repo.nil?
            logger.warn "Repo #{repo_name} doesn't exist"
          else
            logger.info "Clonning #{repo.url} ..."
            git.clone(repo.url, local_repo_root)
          end

        end



        def run
          logger.info "Clonning #{handouts.length} handout(s) into #{local_dir} ..."
          super()
          logger.info "Done."
        end



        def on_process_handout_error(repo_name, index, error)
          backtrace = error.backtrace.join("\n\t")
          logger.error "ERROR - #{error} (#{repo_name}).\n\n#{backtrace}"
        end


      end
    end
  end
end
