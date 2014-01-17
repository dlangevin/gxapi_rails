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

  context "#env" do
    it "should delegate to its class" do
      subject.env.should eql Gxapi.env
    end
  end

  context "#get_variant" do

    it "should make a call to Google Analytics and return a future" do
      variant = subject.get_variant(test_experiment_name)
      valid_variants.should include variant.value.name
      [0, 1].should include variant.value.index
    end

    it "should set a key in the rails cache for a given
      uuid/experiment combo" do

      variant = subject.get_variant(test_experiment_name)
      variant.value

      cache_key = "#{user_key}_untitled_experiment"
      Gxapi.cache.read(cache_key).should have_key("index")

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
      variant.value.name.should eql("default")
      (Time.now - start_time).should be < 2.5
    end

    it "should allow a user to override the chosen variant" do

      variant = subject.get_variant(test_experiment_name, "fakeval")

      variant.value.experiment_id.should be_nil
      variant.value.name.should eql("fakeval")
      variant.value.index.should eql -1

    end


  end


  context "#user_key" do

    it "should set up its user_key" do
      subject.user_key.should eql user_key
    end

  end
end