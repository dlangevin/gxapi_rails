require 'rails/generators'

module Gxapi
  class InstallGenerator < Rails::Generators::Base

    # Description
    desc <<DESC
Description:
    Set up config files for Gxapi

DESC

    class_option :account_id,
      type: :string,
      default: nil,
      desc: "Google Analytics Account ID"

    class_option :profile_id,
      type: :string,
      default: nil,
      desc: "Google Analytics Profile ID"

    class_option :web_property_id,
      type: :string,
      default: nil,
      desc: "Google Analytics Web Property ID"

    class_option :email,
      type: :string,
      default: nil,
      desc: "Google Analytics Service Account Email"


    #
    # Our root for template files
    #
    # @return [String]
    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end

    #
    # Copy our config file over
    #
    # @return [type] [description]
    def copy_config_file
      template "gxapi.yml", "config/gxapi.yml"
    end

  end
end