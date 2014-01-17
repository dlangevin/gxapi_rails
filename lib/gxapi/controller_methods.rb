module Gxapi
  module ControllerMethods

    #
    # Get the variant and set it as an instance variable, handling
    # overriding by passing in the URL
    #
    # @param  identifier [String, Hash] Name for the experiment or ID hash
    # for the experiment
    # @param  ivar_name [String, Symbol] Name for the variable
    #
    # @example
    #
    #   def my_action
    #     gxapi_get_variant("Name")
    #   end
    #
    #   # OR
    #
    #   def my_action
    #     gxapi_get_variant(id: 'id_from_google')
    #   end
    #
    # @return [Celluloid::Future, Gxapi::Ostruct] Variant value
    def gxapi_get_variant(identifier, ivar_name = :variant)
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
        val = self.gxapi_base.get_variant(identifier)
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