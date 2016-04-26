require 'gitomator/task'


module Gitomator
  module Classroom
    module AutoMarker
      class Base < Gitomator::BaseTask

        attr_reader :config

        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::Config::AutoMarker] Parsed configuration object (TODO: Implement it as a subclass of Gitomator::Classroom::Assignment)
        # @param assignment_config [Gitomator::Classroom::Assignment]
        #
        def initialize(context, auto_marker_config)
          super(context)
          @config = auto_marker_config
          @blocks = { :before => [], :after => [] }
        end


        def run()
          @blocks[:before].each {|b| self.instance_exec(&b) }

          # Keep the auto-marker results, for each submission (i.e. each repo)
          repo2mark, repo2error = {}, {}

          config.repos.each_with_index do |repo, index|
            logger.debug "#{repo} (#{index + 1} out of #{config.repos.length})"
            begin
              repo2mark[repo] = auto_mark(repo)
            rescue => e
              logger.error "#{repo} : #{e}\n#{e.backtrace.join("\n\t")}"
              repo2error[repo] = e
            end
          end

          @blocks[:after].each {|b| self.instance_exec(repo2mark, repo2error, &b) }
        end



        #
        # @param repo [String]
        # @return Object
        #
        def auto_mark(repo)
          raise "Unimplemented"
        end


        #
        # Inject a block that will run before any auto-marking takes place.
        # The blocks takes no arguments, and doesn't (need to) return any specific value.
        #
        def before_auto_marking(&block)
          @blocks[:before].push block
        end

        #
        # Inject a block that will run after all auto-marking took place.
        #
        # @yield [repo2mark, repo2error] A block that processes the auto-marker's results.
        # @yieldparam [Hash<String,Object>] repo2mark
        # @yieldparam [Hash<String,Error>]  repo2error
        #
        def after_auto_marking(&block)
          @blocks[:after].push block
        end


      end
    end
  end
end
