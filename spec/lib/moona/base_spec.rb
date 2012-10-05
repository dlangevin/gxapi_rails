require 'spec_helper'

describe Moona::Base do

  before(:all) do
    Moona.config_path = File.expand_path(
      "../../../support/config.yml", __FILE__
    )
    Moona.env = "test"
  end

  #We cache based on the id, so we need to get a random one.
  subject do
    Moona::Base.new(user_key)
  end

  let(:user_key) do
    Kernel.rand(1000000000000000)
  end

  let(:valid_variants) do
    ["variant1", "variant2", "variant3"]
  end

  context "#env" do
    it "should delegate to its class" do
      subject.env.should eql Moona.env
    end
  end
  
  context "#get_token_for_experiment" do

    it "should be able to retrieve a valid token" do
      url = "https://api.mynaweb.com:443/v1/experiment/somelongsha/suggest"
      RestClient.expects(:get).with(url).yields(
        stub(
          :code => 200,
          :body => JSON.unparse({
            "token" => "mytoken", "choice" => "variant1"
          })
        )
        
      )
      subject.get_variant("my_experiment").value
      subject.get_token_for_experiment("my_experiment").should eql("mytoken")
    end

    it "should default to nil if there is not a valid token" do
      subject.get_token_for_experiment("my_experiment").should be_nil
    end

  end

  context "#get_variant" do

    before(:each) do
      url = "https://api.mynaweb.com:443/v1/experiment/somelongsha/suggest"
      RestClient.expects(:get).with(url).yields(
        stub(
          :code => 200,
          :body => JSON.unparse({
            "token" => "mytoken", "choice" => "variant1"
          })
        )
        
      )
    end

    it "should make a call to myna and return a future" do
      variant = subject.get_variant("my_experiment")
      valid_variants.should include variant.value
    end

    it "should set a key in the rails cache for a given 
      uuid/experiment combo" do

      variant = subject.get_variant("my_experiment")
      variant.value

      cache_key = "#{user_key}_my_experiment"
      Moona.cache.read(cache_key).should eql({
        "token" => "mytoken", "choice" => "variant1"
      })

    end

    it "should time out after 1 second and return the default value" do

      Moona.cache.expects(:fetch).yields{sleep(10)}
      start_time = Time.now
      variant = subject.get_variant("my_experiment")
      
      # make sure we return the default value
      variant.value.should eql("variant1")
      (Time.now - start_time).should be < 1.5
    end


  end

  context "#reward_all_experiments" do

    it "should call reward_experiment for each valid experiment" do
      subject.expects(:reward_experiment).with("my_experiment", 1.0)
      subject.expects(:reward_experiment).with("test_experiment", 1.0)
      subject.reward_all_experiments(1.0)
    end

  end


  context "#reward_experiment" do

    
    it "should be able to reward an experiment" do
    
      url = "https://api.mynaweb.com:443/v1/experiment/somelongsha/suggest"
      RestClient.expects(:get).with(url).yields(
        stub(
          :code => 200,
          :body => JSON.unparse({
            "token" => "mytoken", "choice" => "variant1"
          })
        )
        
      )
      # sets our cache values
      subject.get_variant("my_experiment").value

      url = "https://api.mynaweb.com:443/v1/experiment/somelongsha/reward"
      # make sure we make the reward call
      RestClient.expects(:get).with(url, {
        :params => {
          :token => "mytoken",
          :amount => 1.0
        }
      })
      subject.reward_experiment("my_experiment", 1.0).should be true
    end

    it "should return false when a key for an experiment is not found" do
      subject.reward_experiment("my_experiment", 1.0).should be false
    end

  end

  context "#user_key" do
    
    it "should set up its user_key" do
      subject.user_key.should eql user_key
    end

  end

  context "integration" do

    it "should be able to reward a real experiment on Myna" do

      pending "Authentication isn't working with Myna"

      host = "https://api.mynaweb.com:443"
      uri = "/v1/experiment/c4030a09-cddd-4aa3-aa31-abba462b96fc/info"
      experiment_data = RestClient.get(
        host + uri,
        :head => {
          'Accept' => 'application/json',
          "Authorization" => ["developers@lifebooker.com", "lbcup45_p"]
        }
      )
      debugger
      true
    end

  end

end