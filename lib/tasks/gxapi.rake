namespace :gxapi do

  desc "Reload the Google Analytics Experiment data"
  task reload_experiments: :environment do
    Rails.logger.info { "Reloading Gxapi Experiments" }
    Gxapi.reload_experiments
    Rails.logger.info { "Reloading Gxapi Experiments Complete!" }
  end

  desc "Load experiments from API, to verify configuration"
  task verify_config: :environment do
    STDOUT.puts "Loading experiments..."
    experiments = Gxapi.verify.map { |exp| "#{exp['name']} - #{exp['status']}"}
    STDOUT.puts "Experiments #{experiments.join("\n")}"
  end
end
