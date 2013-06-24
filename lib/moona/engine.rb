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
end
