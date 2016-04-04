require "classroom_automator/version"

module ClassroomAutomator


  module ScriptUtil

    require 'trollop'
    require 'classroom_automator/workflow/context'
    require 'classroom_automator/config/assignment'


    def self.parse_cmd_line_opts(usage_message)
      opts = Trollop::options do
        version ClassroomAutomator::VERSION
        banner  usage_message
        opt     :context,
                  "Context configuration file (default: ENV['CLASSROOM_AUTOMATOR_CONTEXT'])",
                  :type => :string
      end

      opts[:context] = opts[:context] || ENV['CLASSROOM_AUTOMATOR_CONTEXT']
      return opts
    end


    def self.validate_argv(expected_length, usage_message)
      if ARGV.length != expected_length
        abort(usage_message)
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
      opts = parse_cmd_line_opts(usage_message)
      validate_argv(1, usage_message)

      run_task(task_class.new(
        ClassroomAutomator::Workflow::Context.from_file(opts[:context]),
        ClassroomAutomator::Config::Assignment.from_file(ARGV[0])
      ))
    end


    def self.run_two_arg_assignment_script(task_class)
      usage_message = "Usage: #{File.basename($0)} ASSIGNMENT-CONF LOCAL-DIR"
      opts = parse_cmd_line_opts(usage_message)
      validate_argv(2, usage_message)

      run_task(task_class.new(
        ClassroomAutomator::Workflow::Context.from_file(opts[:context]),
        ClassroomAutomator::Config::Assignment.from_file(ARGV[0]),
        ARGV[1]
      ))
    end


  end

end
