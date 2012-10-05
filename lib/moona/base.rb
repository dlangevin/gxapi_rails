module Moona
  class Base
    attr_reader :user_key

    # we pass in a user hash to identify the user
    # so that we can keep data 
    def initialize(user_key)
      @user_key = user_key
      @interface = Interface.new
    end

    def env
      Moona.env
    end

    def get_token_for_experiment(experiment_name)
      # val = UserVariant.new(Moona.cache.read(self.cache_key(expiriment_name)))
      if val = Moona.cache.read(self.cache_key(experiment_name))
        return UserVariant.new(val).token
      end
      return nil
    end

    def get_variant(experiment_name)
      Celluloid::Future.new do
        self.get_variant_value(experiment_name)
      end
    end

    def reward_all_experiments(amount)
      Moona.get_all_experiments.each do |experiment_name|
        self.reward_experiment(experiment_name, amount)
      end
    end

    def reward_experiment(experiment_name, amount)
      if token = self.get_token_for_experiment(experiment_name)
        # UUID for this experiment
        self.make_remote_request(:default => false) do
          experiment_uuid = Moona.experiment_uuid(experiment_name)
          @interface.reward_experiment(experiment_uuid, token, amount)
          return true
        end
      end
      return false
    end



    protected
    # cache key for a given experiment and our user
    def cache_key(experiment_name)
      "#{Moona.cache_namespace}#{self.user_key}_#{experiment_name}"
    end

    # protected method to make the actual calls to get values
    # from the cache or from myna
    def get_variant_value(experiment_name)
      
      # UUID for this experiment
      experiment_uuid = Moona.experiment_uuid(experiment_name)
      default_value = Moona.get_default_value_for_experiment(experiment_name)
      
      self.make_remote_request(:default => default_value) do
        resp = Moona.cache.fetch(self.cache_key(experiment_name)) do
          @interface.get_suggestion(experiment_uuid).to_hash
        end
        UserVariant.new(resp).choice || default_value
      end
    end

    def make_remote_request(opts = {}, &block)
      begin
        Timeout::timeout(1.0) do
          yield
        end
      rescue Exception => e
        raise e if Moona.env == "test"
        return opts[:default]
      end
    end

    class UserVariant

      def initialize(data)
        @data = data.is_a?(Hash) ? data.dup : {}
      end

      def choice
        @data["choice"]
      end

      def token
        @data["token"]
      end

      def to_hash
        @data
      end

    end

    class Interface
      
      HOST = "https://api.mynaweb.com:443"

      def get_suggestion(experiment_uuid)
        
        #Myna.experiment(experiment_uuid).suggest.value
        url = "#{HOST}/v1/experiment/#{experiment_uuid}/suggest"
        data = {}

        RestClient.get(url) do |response|
          case response.code
            when 200..299
              data = JSON.parse(response.body)
          end
        end
        UserVariant.new(data)
      end

      def reward_experiment(experiment_uuid, token, amount)
        url = "#{HOST}/v1/experiment/#{experiment_uuid}/reward"
        RestClient.get(url, :params => {
          :token => token,
          :amount => amount
        })
      end
    end
  end
end