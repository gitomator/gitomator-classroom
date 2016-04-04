require "classroom_automator/version"

module ClassroomAutomator


  module Script

    require 'trollop'
    require 'classroom_automator/workflow/context'
    require 'classroom_automator/config/assignment'


    class OptParser < Trollop::Parser

      def initialize(usage_message)
        super
        version ClassroomAutomator::VERSION
        usage   usage_message
        opt     :context,
                "Context configuration file (default: ENV['CLASSROOM_AUTOMATOR_CONTEXT'])",
                :type => :string
      end

      def parse(cmdline)
        opts = super
        opts[:context] = opts[:context] || ENV['CLASSROOM_AUTOMATOR_CONTEXT']
        return opts
      end

    end



    def self.run_task(task_obj)
      begin
        task_obj.run
      rescue => e
        abort "ERROR: #{e}.\n\n#{e.backtrace.join("\n\t")}"
      end
    end



    def self.run_single_arg_assignment_script(task_class)
      usage_message = "Usage: #{File.basename($0)} ASSIGNMENT-CONF"
      opts = OptParser.new(usage_message).parse(ARGV)
      abort usage_message if ARGV.length != 1

      run_task(task_class.new(
        ClassroomAutomator::Workflow::Context.from_file(opts[:context]),
        ClassroomAutomator::Config::Assignment.from_file(ARGV[0])
      ))
    end


    def self.run_two_arg_assignment_script(task_class)
      usage_message = "Usage: #{File.basename($0)} ASSIGNMENT-CONF LOCAL-DIR"
      opts = OptParser.new(usage_message).parse(ARGV)
      abort usage_message if ARGV.length != 2

      run_task(task_class.new(
        ClassroomAutomator::Workflow::Context.from_file(opts[:context]),
        ClassroomAutomator::Config::Assignment.from_file(ARGV[0]),
        ARGV[1]
      ))
    end


  end

end
