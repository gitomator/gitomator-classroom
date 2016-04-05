require 'classroom_automator/task/assignment_base'

module ClassroomAutomator
  module Task
    class CloneHandouts < ClassroomAutomator::Task::AssignmentBase


      def initialize(context, assignment_config, local_dir)
        raise "No such folder, #{local_dir}." unless Dir.exists? local_dir
        super(context, assignment_config, local_dir)
      end


      def run
        logger.info "Clonning #{handouts.length} handout(s) into #{local_dir} ..."
        super()
        logger.info "Done."
      end


      def process_handout(repo_name, i)
        super

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



    end
  end
end
