require 'yaml'
require 'erb'


module ClassroomAutomator
  module Config
    module Util

      #
      # @param conf_file [String/File]
      # @return Hash
      #
      def self.conf_file_to_hash(conf_file)
        if conf_file.respond_to? :read
          YAML::load(ERB.new(conf_file.read).result)
        else
          YAML::load(ERB.new(File.read(conf_file)).result)
        end
      end

    end
  end
end
