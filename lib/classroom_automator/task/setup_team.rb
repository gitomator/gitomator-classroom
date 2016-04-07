require 'classroom_automator/task/base'
require 'set'

module ClassroomAutomator
  module Task

    #
    # Given ClassroomAutomator::Team object, which includes:
    #  - The team's name
    #  - Team memberships (Hash<String,String> mapping username to role)
    # Create the team, if it's missing, and create or update all team memberships.
    #
    # Note: This task doesn't remove team memberships.
    #
    class SetupTeam < ClassroomAutomator::Task::Base


      #
      # @param context [ClassroomAutomator::Context]
      # @param team [ClassroomAutomator::Team]
      #
      def initialize(context, team)
        super(context)
        @team = team
      end



      def run
        create_team_if_missing()
        @team.members.each do |username, role|
          begin
            create_or_update_membership(username, role)
          rescue => e
            logger.error("Cannot register #{username} - #{e}.")
          end
        end
      end


      def create_team_if_missing
        if hosting.read_team(@team.name).nil?
          logger.info("Creating the '#{@team.name}' team.")
          hosting.create_team(@team.name)
        else
          logger.debug("Team '#{@team.name}' exists.")
        end
      end


      def create_or_update_membership(username, role)
        membership = hosting.read_team_membership(@team.name, username)
        if membership.nil?
          logger.info("Adding #{username} to team #{@team.name} (role: #{role}).")
          hosting.create_team_membership(@team.name, username, {:role => role})
        elsif _get_role(membership) != role
          logger.info("Updating #{username}'s role from #{_get_role(membership)} to #{role} (team: #{@team.name})")
          hosting.update_team_membership(@team.name, username, {:role => role})
        else
          logger.debug("Skipping #{username}, already a #{role} of #{@team.name}.")
        end
      end


      # FIXME: This is a hack, code that needs to be in gitomator and gitomator-github
      #        is actually implemented here.
      #
      # At the moment, the Gitomator libraries are not finished, so we get a team
      # membership in whatever format Octokit chooses to return it (Hash<Symbol,String>)
      #
      def _get_role(membership)
        membership[:role] == 'maintainer' ? 'admin' : 'member'
      end


    end
  end
end
