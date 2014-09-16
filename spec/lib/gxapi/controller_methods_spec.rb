require 'spec_helper'

module Gxapi
  describe ControllerMethods do

    subject { ApplicationController }

    its(:action_methods) { should_not include 'gxapi_get_variant' }
  end
end