require 'trollop'
require 'gitomator/classroom/version'


module Gitomator
  module Classroom
    module ScriptUtil

      DEFAULT_CONTEXT_ENV_VAR_NAME = 'GITOMATOR_CLASSROOM_CONTEXT'

      def self.default_context_file
        ENV[DEFAULT_CONTEXT_ENV_VAR_NAME]
      end

      #---------------------------------------------------------------------------

      class DefaultOptionParser < Trollop::Parser

        def initialize(help_text)
          super()
          banner "#{help_text}\nOptions:"
          version "Gitomator Classroom #{Gitomator::Classroom::VERSION} (c) 2016 Joey Freund"

          context_description = "YAML configuration for various service providers (e.g. GitHub hosting, or Travis CI)."
          unless ENV[DEFAULT_CONTEXT_ENV_VAR_NAME]
            context_description += "\nYou can set a default configuration file by setting the #{DEFAULT_CONTEXT_ENV_VAR_NAME} environment variable."
          end

          opt :context, context_description ,
                :type => :string,
                :default => ScriptUtil::default_context_file

        end

        def parse(args)
          return { :context => ScriptUtil::default_context_file }.merge(
            Trollop::with_standard_exception_handling(self) { super(args)  }
          )
        end

      end

      #---------------------------------------------------------------------------

      #
      # @param task [Gitomator::Task::*] An object with a run() method.
      #
      def self.run_task(task)
        begin
          task.run
        rescue => e
          abort "ERROR: #{e}.\n\n#{e.backtrace.join("\n\t")}"
        end
      end

      #
      # @param tasks [Array<Gitomator::Task::*>]
      #
      def self.run_tasks(tasks)
        begin
          tasks.each { |task| task.run }
        rescue => e
          abort "ERROR: #{e}.\n\n#{e.backtrace.join("\n\t")}"
        end
      end

      #
      # @return [Gitomator::Classroom::Context]
      #
      def self.context_from_file(config_file)
        require 'gitomator/classroom/context'
        Gitomator::Classroom::Context.from_file(config_file)
      end

      #
      # @return [Gitomator::Classroom::Assignment]
      #
      def self.assignment_config_from_file(config_file)
        require 'gitomator/classroom/config/assignment'
        Gitomator::Classroom::Config::Assignment.from_file(config_file)
      end

      #
      # @return [Hash<String,Gitomator::Classroom::Team>]
      #
      def self.teams_from_file(config_file)
        require 'gitomator/classroom/config/team'
        Gitomator::Classroom::Config::Team.from_file(config_file)
      end

      #---------------------------------------------------------------------------


    end
  end
end
