require 'spec_helper'

module Moona

  describe GoogleAnalytics do

    before(:each) do
      Moona.cache.clear
    end

    context "#get_experiments" do

      it "gets a list of experiments" do
        experiments = subject.get_experiments
        experiments.first.should be_a(Moona::Ostruct)
      end

    end

    context "#get_experiment" do

      it "should filter by name" do 
        experiment = subject.get_experiments.first

        subject.get_experiment(experiment.name).should eql(experiment)
      end

    end

    context "#get_variant" do

      before(:each) do
        subject.stubs(
          :get_experiment => Ostruct.new({
            :id => "123",
            :name => "X",
            :variations => [
              Ostruct.new(
                :name => "original", 
                :weight => 0.5, 
                :status => "ACTIVE"
              ),
              Ostruct.new(
                :name => "variation1",
                :weight => 0.5,
                :status => "ACTIVE"
              )
            ]
          })
        )
      end

      it "should return a variant determined by weight" do
        variant = subject.get_variant("fakename")
        ["original", "variation1"].should include variant.name
        [0, 1].should include variant.index
      end

    end
    
  end

end