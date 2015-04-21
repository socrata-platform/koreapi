require 'parseconfig'

module Sinatra
  module KoreaPI
    module ConfigUtils

      CONFIG_FILE_PATH = "/etc/koreapi.properties"

      # -----------------------------------------------------------------------------------------------
      # Returns the first Attribute value for the provided attribute key.  Nil is returned
      # if the key is inexistent.
      #
      # key: Attribute key within the property file. Ex. <key> = <value>
      # config_file_path: The configuration file path.
      # return the first non nil attribute.
      # -----------------------------------------------------------------------------------------------
      def self.get_first_attr(key, config_file_path = CONFIG_FILE_PATH, default_value = nil)
        vals = get_attrs(key, get_config_file_or_defaults(config_file_path))
        return vals.find{|s| !s.nil?} unless vals.nil? or vals.empty?
        return default_value
      end

      # -----------------------------------------------------------------------------------------------
      # Returns an array of all the attribute values.  This assumes that attribute values
      # are ',' separated.  nil is returned if the key is inexistent.
      #
      # key: Attribute key within the property file. Ex. <key> = <value>
      # config_file_path: The configuration file path.
      # returns An array of all the attribute values.
      # -----------------------------------------------------------------------------------------------
      def self.get_attrs(key, config_file_path = CONFIG_FILE_PATH, default_value = [])
        raw_value = get_config(get_config_file_or_defaults(config_file_path))[key]
        return raw_value.split(',') unless raw_value.nil?
        return default_value
      end

      private

      # -----------------------------------------------------------------------------------------------
      # Tests to see if the config file passed exists and returns a valid config path.       #
      #
      # config_file_path: The file path of the configuration file
      #
      # returns: A valid path to a config file. If path passed does not exists, it returns the path
      #   to the default configuration file included in the repo. Otherwise, it returns
      #   the path passed.
      # -----------------------------------------------------------------------------------------------
      def self.get_config_file_or_defaults(config_file_path)
        if File.exists?(config_file_path)
          config_file_path
        else
          $log.error("File path: " + config_file_path + " does not exist using defaults from "\
                     "'./koreapi.default.properties'. If you are not a developer, you probably "\
                     "do not want this to happen.")
          "./koreapi.default.properties"
        end
      end

      # -----------------------------------------------------------------------------------------------
      # Returns the parsed configuration file hash.
      #
      # config_file_path: The file path of the configuration file
      # returns: ParseConfig instance which represents the configuration reflected at
      #   the property value.
      # -----------------------------------------------------------------------------------------------
      def self.get_config(config_file_path = CONFIG_FILE_PATH)
        return ParseConfig.new(get_config_file_or_defaults(config_file_path))
      end

    end
  end
end
