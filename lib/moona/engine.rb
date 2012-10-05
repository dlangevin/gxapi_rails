module Moona
  class Engine < Rails::Railtie
    config.after_initialize do
      Moona.cache = Rails.cache
    end
  end
end