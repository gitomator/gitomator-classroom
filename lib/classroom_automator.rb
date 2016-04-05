require "classroom_automator/version"

module ClassroomAutomator

  module Util

    #
    # Given a config file (path to file, or an object that responds to :read),
    # do that ERB+YAML thing, and return a Hash.
    #
    # @param config [String/File]
    # @return Hash
    #
    def self.load_config(config)
      require 'erb'
      require 'yaml'

      if config.respond_to? :read
        YAML::load(ERB.new(config.read).result)
      else
        YAML::load(ERB.new(File.read(config)).result)
      end
    end


  end

end
