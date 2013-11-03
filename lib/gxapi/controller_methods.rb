module Gxapi
  module ControllerMethods

    #
    # Get the variant and set it as an instance variable, handling
    # overriding by passing in the URL
    #
    # @param  experiment_name [String] Name for the experiment
    # @param  ivar_name [String, Symbol] Name for the variable
    #
    # @return [Celluloid::Future, Gxapi::Ostruct] Variant value
    def gxapi_get_variant(experiment_name, ivar_name = :variant)
      # handle override
      if params[ivar_name]
        val = Gxapi::Ostruct.new(
          value: {
            index: -1,
            experiment_id: nil,
            name: params[ivar_name]
          }
        )
      else
        val = self.gxapi_base.get_variant(experiment_name)
      end
      return instance_variable_set("@#{ivar_name}", val)
    end

    protected

    def gxapi_base
      @gxapi_base ||= begin
        Gxapi::Base.new(self.gxapi_token)
      end
    end

    def gxapi_token
      cookies[:gxapi] ||= SecureRandom.hex(16)
    end

  end
end