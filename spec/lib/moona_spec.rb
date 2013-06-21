require 'spec_helper'

describe Moona do

  before(:all) do
    Moona.config_path = File.expand_path(
      "../../support/config.yml", __FILE__
    )
    Moona.env = "test"
  end

  context ".cache" do
    it "should have a cache that gets defined by default" do
      Moona.cache.should be_kind_of(ActiveSupport::Cache::Store)
    end

    context "with Rails" do

      it "should use the Rails cache once it is available" do
        Moona.cache.should be Rails.cache
      end

      it "should still allow you to override the cache"

    end
  end

end
