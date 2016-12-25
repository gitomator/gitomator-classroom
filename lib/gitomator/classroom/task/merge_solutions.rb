require 'gitomator/task'

module Gitomator
  module Classroom
    module Task
      class MergeSolutions < Gitomator::BaseTask

        attr_reader :solution_label

        #
        # @param context - A context
        # @param repos [Array<String>] The handout repos
        # @param opts [Hash]
        #   @option :throttle [Number] In seconds
        #
        def initialize(context, repos, solution_label='solution', opts = {})
          super(context)
          @repos = repos
          @solution_label = solution_label
          @opts  = opts
        end


        def run
          logger.debug "Merging solutions from #{@repos.length} handout(s)."

          @repos.each_with_index do |repo_name, index|
            logger.info "#{repo_name} (#{index + 1} out of #{@repos.length})"
            begin
              merge_solution(repo_name, index)
              throttle()
            rescue => e
              on_error(repo_name, index, e)
            end
          end

          logger.debug "Done."
        end





        def merge_solution(repo_name, index)
          if has_merged_solution?(repo_name)
            logger.info "Skipping #{repo_name}, solution was already merged"
            return
          end

          pr = get_unmerged_pull_request(repo_name)
          if pr.nil?
            logger.info "No solution submitted for #{repo_name}."
            return
          end

          logger.info "About to merge pull-request #{pr.id} for repo #{repo_name} ..."
          hosting.merge_pull_request(repo_name, pr.id, 'Merging solution')
          tagging.add_tags(repo_name, pr.id, solution_label)
        end


        def throttle()
          if @opts[:throttle]
            logger.debug "About to sleep for #{@opts[:throttle]} second(s) ..."
            sleep(@opts[:throttle])
          end
        end



        def has_merged_solution?(repo_name)
          return tagging.search(repo_name, solution_label).length > 0
        end

        def get_unmerged_pull_request(repo_name)
          prs = hosting.read_pull_requests(repo_name, { :state => :open})
          return nil if prs.length == 0
          logger.warn("#{repo_name} has #{prs.length} open PR's") if prs.length > 1
          return prs[0]
        end


        def on_error(repo_name, index, err)
          logger.error "#{err} (#{repo_name}).\n\n#{err.backtrace.join("\n\t")}"
        end

      end
    end
  end
end
