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
      Moona.cache.should be_instance_of(ActiveSupport::Cache::MemoryStore)
    end

    context "with Rails" do

      before(:all) do
        module Rails
          def self.cache
            @cache ||= ActiveSupport::Cache::MemoryStore.new
          end
        end
      end

      after(:all) do
        Object.send(:remove_const, :Rails)
      end

      it "should use the Rails cache once it is available" do
        Moona.cache.should be Rails.cache
      end

      it "should still allow you to override the cache"

    end
  end

  context ".get_all_experiments" do
    it "should be able to get the names of all experiments" do
      Moona.get_all_experiments.should eql(
        ["my_experiment", "test_experiment"]
      )
    end
  end

end
