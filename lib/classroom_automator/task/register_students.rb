require 'classroom_automator/task/base'
require 'set'

module ClassroomAutomator
  module Task
    class RegisterStudents < ClassroomAutomator::Task::Base


      #
      # @param context [ClassroomAutomator::Context]
      # @param students [Collection<String>] Student usernames
      # @param students_team [String] The name of the team containing students (default is 'Students')
      #
      def initialize(context, students, students_team='Students')
        super(context)
        @students  = students
        @team_name = students_team
      end




      def run
        # Create the team if it doesn't exist
        if hosting.read_team(@team_name).nil?
          logger.info("Creating the '#{@team_name}' team.")
          hosting.create_team(@team_name)
        end

        @students.to_set.each do |username|
          begin
            if hosting.read_team_membership(@team_name, username).nil?
              logger.info("Registering #{username} ...")
              hosting.create_team_membership(@team_name, username)
            else
              logger.info("Skipping #{username}, already registered.")
            end
          rescue => e
            logger.error("Cannot register #{username} - #{e}.")
          end
        end

      end


    end
  end
end
