require 'spec_helper'

describe Gxapi do

  before(:all) do
    Gxapi.config_path = File.expand_path(
      "../../support/config.yml", __FILE__
    )
    Gxapi.env = "test"
  end

  context ".cache" do
    it "should have a cache that gets defined by default" do
      expect(Gxapi.cache).to be_kind_of(ActiveSupport::Cache::Store)
    end

    context "with Rails" do

      it "should use the Rails cache once it is available" do
        expect(Gxapi.cache).to be Rails.cache
      end

      it "should still allow you to override the cache" do
        my_cache = stub()
        Gxapi.cache = my_cache
        expect(Gxapi.cache).to eql(my_cache)
      end

    end
  end

end
