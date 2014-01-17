require 'google/api_client'

module Gxapi
  class GoogleAnalytics

    CACHE_KEY = "gxapi-google-analytics-experiments"

    #
    # Gets the experiment that has this name or ID
    #
    # @param identifier [ExperimentIdentifier] Identifier object for the
    # experiment
    #
    # @return [Gxapi::Ostruct]
    def get_experiment(identifier)
      self.get_experiments.find { |e| identifier.matches_experiment?(e)}
    end

    #
    # return a list of all experiments
    #
    # @return [Array<Gxapi::Ostruct>]
    def get_experiments
      @experiments ||= begin
        # fetch our data from the cache
        data = Gxapi.with_error_handling do
          # handle caching
          self.list_experiments_from_cache
        end
        # turn into Gxapi::Ostructs
        (data || []).collect{|data| Ostruct.new(data)}
      end
    end

    #
    # get a variant for an experiment
    #
    # @param identifier [String, Hash] Either the experiment name
    # as a String or a hash of what to look for
    #
    # @return [Gxapi::Ostruct]
    def get_variant(identifier)
      # pull in an experiment
      experiment = self.get_experiment(identifier)

      if self.run_experiment?(experiment)
        # select variant for the experiment
        variant = self.select_variant(experiment)
        # return if it it's present
        return variant if variant.present?
      end
      # return blank value if we don't have an experiment or don't get
      # a valid value
      return Ostruct.new(
        name: "default",
        index: -1,
        experiment_id: nil
      )
    end

    #
    # reset and return a list of all experiments
    #
    # @return Array [Gxapi::Ostruct]
    def reload_experiments
      Gxapi.cache.delete(CACHE_KEY)
      self.get_experiments
    end

    protected

    #
    # Api definition for analytics api
    #
    # @return [Google::APIClient::API] Discovered Analytics endpoint
    def analytics
      @analytics ||= self.client.discovered_api('analytics', 'v3')
    end


    #
    # Discovered definition of Analytics Experiments
    #
    # @return [Google::APIClient::API] Discovered Analytics endpoint
    def analytics_experiments
      self.analytics.management.experiments
    end

    #
    # Accessor for Google Analytics config
    #
    # @return [Ostruct] Configuration
    def config
      Gxapi.config.google_analytics
    end

    #
    # google api client
    #
    # @return [Google::APIClient]
    def client
      @client ||= begin
        client = Google::APIClient.new
        # key stuff is hardcoded for now
        key = Google::APIClient::KeyUtils.load_from_pkcs12(
          Gxapi.config.google.private_key_path, 'notasecret'
        )
        client.authorization = Signet::OAuth2::Client.new(
          token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
          audience: 'https://accounts.google.com/o/oauth2/token',
          scope: 'https://www.googleapis.com/auth/analytics.readonly',
          issuer: Gxapi.config.google.email,
          signing_key: key
        )
        client.authorization.fetch_access_token!
        client
      end
    end

    #
    # List all experiments for our account
    #
    # @return [Array<Gxapi::Ostruct>] Collection of Experiment data
    # retrieved from Google's API
    def list_experiments
      response =  self.client.execute({
        api_method: self.analytics_experiments.list,
        parameters: {
          accountId: self.config.account_id.to_s,
          profileId: self.config.profile_id.to_s,
          webPropertyId: self.config.web_property_id
        }
      })
      response.data.items.collect(&:to_hash)
    end

    #
    # List all experiments for our account, fetching from cache first
    #
    # @return [Array<Gxapi::Ostruct>] Collection of Experiment data from
    # our cache or Google's API
    def list_experiments_from_cache
      Gxapi.cache.fetch(CACHE_KEY) do
        self.list_experiments
      end
    end

    #
    # should we run this experiment under the current conditions?
    #
    # @return [Boolean] should_run
    def run_experiment?(experiment)
      # a blank experiment can't run
      return false if experiment.nil?

      # get a random value - a 100% coverage is represented
      # as 1.0, so Kernel.rand works for us as its max is
      # 1.0
      return experiment.traffic_coverage >= Kernel.rand
    end

    #
    # Select a variant from a given experiment
    #
    # @param  experiment [Ostruct] The experiment to choose for
    #
    # @return [Ostruct, nil] The selected variant or nil if none is
    # selected
    def select_variant(experiment)
      # starts off at 0
      accum = 0.0
      sample = Kernel.rand

      # go through our experiments and return the variation that matches
      # our random value
      experiment.variations.each_with_index do |variation, i|

        # we want to record the index in the array for this variation
        variation.index = i
        variation.experiment_id = experiment.id

        # add the variation's weight to accum
        accum += variation.weight

        # return the variation if accum is more than our random value
        if sample <= accum
          return variation
        end
      end
      # default to nil
      return nil
    end

  end
end