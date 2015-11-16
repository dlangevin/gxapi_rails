require 'spec_helper'

describe Gxapi::Base do

  #We cache based on the id, so we need to get a random one.
  subject do
    Gxapi::Base.new(user_key)
  end

  let(:user_key) do
    Kernel.rand(1000000000000000)
  end

  let(:valid_variants) do
    ["original", "variant1"]
  end

  let(:test_experiment_name) do
    "Untitled experiment"
  end

  let(:test_experiment_id) do
    "lj5s_ZvWSJSZLphnkpP-Xw"
  end

  let(:stub_experiments) do
    Gxapi::Ostruct.new({
      id: test_experiment_id,
      name: test_experiment_name,
      traffic_coverage: 1.0,
      variations: [
        Gxapi::Ostruct.new(
          name: 'original',
          weight: 0.5,
          status: 'ACTIVE'
        ),
        Gxapi::Ostruct.new(
          name: 'variant1',
          weight: 0.5,
          status: 'ACTIVE'
        )
      ]
    })
  end

  context "#env" do
    it "should delegate to its class" do
      expect(subject.env).to eql Gxapi.env
    end
  end

  before(:each) do
    Gxapi::GoogleAnalytics.any_instance.stubs(:get_experiment).returns(stub_experiments)
  end

  context "#get_variant" do

    it "should make a call to Google Analytics and return a future" do
      variant = subject.get_variant(test_experiment_name)
      expect(valid_variants).to include variant.value.name
      expect([0, 1]).to include variant.value.index
    end

    it "should set a key in the rails cache for a given
      uuid/experiment combo" do

      variant = subject.get_variant(test_experiment_name)
      variant.value

      cache_key = "#{user_key}_untitled_experiment"
      expect(Gxapi.cache.read(cache_key)).to include("index")

    end

    it "lets us search by experiment id" do

      variant = subject.get_variant(id: test_experiment_id)
      expect(variant.value.experiment_id).to eql(test_experiment_id)

    end

    it "should time out after 2 seconds and return the default value" do

      Gxapi.cache.stubs(:fetch).yields{sleep(3)}
      start_time = Time.now

      variant = subject.get_variant(test_experiment_name)

      # make sure we return the default value
      expect(variant.value.name).to eql("default")
      expect(Time.now - start_time).to be < 2.5
    end

    it "should allow a user to override the chosen variant" do

      variant = subject.get_variant(test_experiment_name, "fakeval")

      expect(variant.value.experiment_id).to be_nil
      expect(variant.value.name).to eql("fakeval")
      expect(variant.value.index).to eql -1

    end


  end


  context "#user_key" do

    it "should set up its user_key" do
      expect(subject.user_key).to eql user_key
    end

  end
end
