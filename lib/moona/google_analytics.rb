require 'google/api_client'

module Moona
  class GoogleAnalytics

    CACHE_KEY = "moona-google-analytics-experiments"

    # gets the experiment that has this name
    def get_experiment(name)
      self.get_experiments.find{|experiment| experiment.name == name}
    end

    # return a list of all experiments
    # @return Array [Ostruct]
    def get_experiments
      @experiments ||= begin
        # fetch our data from the cache
        data = Moona.with_error_handling do
          Moona.cache.fetch(CACHE_KEY) do
            response =  self.client.execute({
              :api_method => self.analytics.management.experiments.list,
              :parameters => {
                :accountId => Moona.config.google_analytics.account_id.to_s,
                :profileId => Moona.config.google_analytics.profile_id.to_s,
                :webPropertyId => 
                  Moona.config.google_analytics.web_property_id
              }
            })
            response.data.items.collect(&:to_hash)
          end
        end
        # turn into Ostructs
        (data || []).collect{|data| Ostruct.new(data)}
      end
    end

    # get a variant for an experiment
    # @return Ostruct
    def get_variant(experiment_name)
      # pull in an experiment
      if experiment = self.get_experiment(experiment_name)
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
      end
      # return blank value if we don't have an experiment or don't get
      # a valid value
      return Ostruct.new(
        :name => "default", :index => -1, :experiment_id => nil
      )
    end


    # reset and return a list of all experiments
    # @return Array [Ostruct]
    def reset_experiments
      Moona.cache.delete(CACHE_KEY)
      self.get_experiments
    end

    protected

    # api definition for analytics api
    def analytics
      @analytics ||= self.client.discovered_api('analytics', 'v3')
    end

    # google api client
    # @return GoogleAPIClient
    def client
      @client ||= begin
        client = Google::APIClient.new
        # key stuff is hardcoded for now
        key = Google::APIClient::KeyUtils.load_from_pkcs12(
          Moona.config.google.private_key_path, 'notasecret'
        )
        client.authorization = Signet::OAuth2::Client.new(
          :token_credential_uri => 
            'https://accounts.google.com/o/oauth2/token',
          :audience => 
            'https://accounts.google.com/o/oauth2/token',
          :scope => 
            'https://www.googleapis.com/auth/analytics.readonly',
          :issuer => Moona.config.google.email,
          :signing_key => key
        )
        client.authorization.fetch_access_token!
        client
      end
    end

  end
end