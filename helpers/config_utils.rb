require 'parseconfig'

module Sinatra
  module KoreaPI
    module ConfigUtils

      CONFIG_FILE_PATH = "/etc/koreapi.properties"

      # -----------------------------------------------------------------------------------------------
      # Returns the configuration file.  If the
      #
      # config_file_path: The file path of the configuration file
      # returns: ParseConfig instance which represents the configuration reflected at
      #   the property value.
      # -----------------------------------------------------------------------------------------------
      def self.get_config(config_file_path = CONFIG_FILE_PATH)
        return ParseConfig.new(config_file_path)
      end


      # -----------------------------------------------------------------------------------------------
      # Returns the first Attribute value for the provided attribute key
      #
      # key: Attribute key within the property file. Ex. <key> = <value>
      # config_file_path: The configuration file path.
      # return the first non nil attribute.
      # -----------------------------------------------------------------------------------------------
      def self.get_first_attr(key, config_file_path = CONFIG_FILE_PATH)
        return get_attrs(key, config_file_path).find{|s| !s.nil?}
      end

      # -----------------------------------------------------------------------------------------------
      # Returns an array of all the attribute values.  This assumes that attribute values
      # are ',' separated.
      #
      # key: Attribute key within the property file. Ex. <key> = <value>
      # config_file_path: The configuration file path.
      # returns An array of all the attribute values.
      # -----------------------------------------------------------------------------------------------
      def self.get_attrs(key, config_file_path = CONFIG_FILE_PATH)
        return get_config(config_file_path)[key].split(',')
      end

    end
  end
end