if Rails::VERSION::MAJOR >= 3  
  module Moona
    class Engine < Rails::Engine
      config.after_initialize do
        Moona.cache = Rails.cache
        # add our helper
        ApplicationHelper.send(:include, MoonaHelper)
      end
    end
  end
else
  require File.expand_path('../../app/helpers/moona_helper', __FILE__)
end
