require 'gitomator/task'

module Gitomator
  module Classroom
    module Task
      class AssignmentBase < Gitomator::BaseTask

        #
        # @param context - A context
        # @param assignment [Gitomator::Classroom::Config::Assignment]
        #
        def initialize(context, assignment)
          super(context)
          @assignment = assignment
        end

        def repos
          @assignment.repos
        end


        def run
          before_any()

          repos.each_with_index do |repo_name, index|
            begin
              process_repo(repo_name, index)
            rescue => e
              on_process_repo_error(repo_name, index, e)
            end
          end

          after_all()
        end


        def before_any()
          logger.debug "About to process #{repos.length} repos ..."
        end

        def process_repo(repo_name, index)
          logger.debug "#{repo_name} (#{index + 1} out of #{repos.length})"
        end

        def on_process_repo_error(repo_name, index, err)
          logger.error "#{err} (#{repo_name}).\n\n#{err.backtrace.join("\n\t")}"
        end

        def after_all()
          logger.debug "Finished processing #{repos.length} repos"
        end

      end
    end
  end
end
