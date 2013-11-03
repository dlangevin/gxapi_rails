module Gxapi
  class Base

    TIMEOUT = 2.0

    attr_reader :user_key

    #
    # @param user_key [String] identifier for our user - this is used in
    # the cache_key
    def initialize(user_key)
      @user_key = user_key
      @interface = GoogleAnalytics.new
    end

    # get the {Gxapi.env}
    def env
      Gxapi.env
    end

    #
    # get all experiments
    #
    # @return [Array<Ostruct>]
    def get_experiments
      @interface.get_experiments
    end

    #
    # return a variant value
    #
    # @example
    #   variant = @gxapi.get_variant("my_experiment")
    #   variant.value =>
    #     # Ostruct.new(experiment_id: "x", index: 1, name: "name")
    #
    # @return [Celluloid::Future]
    def get_variant(experiment_name, override = nil)
      Celluloid::Future.new do
        # allows us to override and get back a variant
        # easily that conforms to the api
        if override.nil?
          self.get_variant_value(experiment_name)
        else
          Ostruct.new(self.default_values.merge(name: override))
        end
      end
    end

    #
    # reload the experiment cache from the remote
    #
    # @return [Boolean] true
    def reload_experiments
      @interface.reload_experiments
      true
    end

    protected

    #
    # cache key for a given experiment and our user
    #
    # @param experiment_name [String] The name of our experiment
    #
    # @return [String] The cache key
    def cache_key(experiment_name)
      experiment_name = experiment_name.downcase.gsub(/\s+/,'_')
      "#{Gxapi.cache_namespace}#{self.user_key}_#{experiment_name}"
    end

    #
    # Default hash values for when a variant isn't found
    #
    # @return [Hash] Default values for when something goes wrong
    def default_values
      {name: "default", index: -1, experiment_id: nil}
    end

    #
    # protected method to make the actual calls to get values
    # from the cache or from Google
    #
    # @param experiment_name [String] Experiment name to look for
    #
    # @return [Gxapi::Ostruct] Experiment data
    def get_variant_value(experiment_name)
      data = Gxapi.with_error_handling do
        Timeout::timeout(2.0) do
          Gxapi.cache.fetch(self.cache_key(experiment_name)) do
            @interface.get_variant(experiment_name).to_hash
          end
        end
      end
      Ostruct.new(
        data.is_a?(Hash) ? data : self.default_values
      )
    end
  end
end