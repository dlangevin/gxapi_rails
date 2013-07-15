module Moona
  class Base
    attr_reader :user_key

    # @param user_key String identifier for our user - this is used in the cache_key
    def initialize(user_key)
      @user_key = user_key
      @interface = GoogleAnalytics.new
    end

    # get the {Moona.env}
    def env
      Moona.env
    end

    # get all experiments
    # @return Array<Ostruct>
    def get_experiments
      @interface.get_experiments
    end

    # return a variant value
    # @example
    #   variant = @moona.get_variant("my_experiment")
    #   variant.value => 
    #     # Ostruct.new(:experiment_id => "x", :index => 1, :name => "name")
    # @return Celluloid::Future
    def get_variant(experiment_name, override = nil)
      Celluloid::Future.new do
        # allows us to override and get back a variant
        # easily that conforms to the api
        if override.nil?
          self.get_variant_value(experiment_name)
        else
          Ostruct.new(:name => override, :index => -1, :experiment_id => nil)
        end
      end
    end

    # reload the experiment cache from the remote
    def reset_experiments
      @interface.reset_experiments
    end

    protected
    # cache key for a given experiment and our user
    def cache_key(experiment_name)
      experiment_name = experiment_name.downcase.gsub(/\s+/,'_')
      "#{Moona.cache_namespace}#{self.user_key}_#{experiment_name}"
    end

    # protected method to make the actual calls to get values
    # from the cache or from myna
    def get_variant_value(experiment_name)
      data = Moona.with_error_handling do
        Timeout::timeout(1.0) do
          Moona.cache.fetch(self.cache_key(experiment_name)) do
            @interface.get_variant(experiment_name).to_hash
          end
        end
      end
      Ostruct.new(
        data || {:name => "default", :index => -1, :experiment_id => nil}
      )
    end
  end
end