require 'spec_helper'

describe Moona do

  before(:all) do
    Moona.config_path = File.expand_path(
      "../../support/config.yml", __FILE__
    )
    Moona.env = "test"
  end

  context ".cache" do
    it "should have a cache" do
      Moona.cache.should be_instance_of(ActiveSupport::Cache::MemoryStore)
    end
  end

  context ".get_all_experiments" do
    it "should be able to get the names of all experiments" do
      Moona.get_all_experiments.should eql(["my_experiment"])
    end
  end

end
