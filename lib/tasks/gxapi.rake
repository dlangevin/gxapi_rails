namespace :gxapi do

  desc "Reload the Google Analytics Experiment data"
  task reload_experiments: :environment do
    Rails.logger.info { "Reloading Gxapi Experiments" }
    Gxapi.reload_experiments
    Rails.logger.info { "Reloading Gxapi Experiments Complete!" }
  end

end