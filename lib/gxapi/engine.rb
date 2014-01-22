if Rails::VERSION::MAJOR >= 3
  module Gxapi
    class Engine < Rails::Engine

      config.after_initialize do
        Gxapi.cache = Rails.cache
      end

      config.to_prepare do
        # add our helper
        ApplicationHelper.send(:include, GxapiHelper)
        ApplicationController.send(:include, Gxapi::ControllerMethods)
      end
    end
  end
else
  require File.expand_path('../../../app/helpers/gxapi_helper', __FILE__)
end
