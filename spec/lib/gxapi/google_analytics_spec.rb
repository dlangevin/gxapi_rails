require 'spec_helper'

module Gxapi

  describe GoogleAnalytics do

    before(:each) do
      Gxapi.cache.clear
    end

    context "#get_experiments" do

      it "gets a list of experiments" do
        experiments = subject.get_experiments
        experiments.first.should be_a(Gxapi::Ostruct)
      end

    end

    context "#get_experiment" do

      it "should filter by name" do
        experiment = subject.get_experiments.first
        identifier = GxApi::ExperimentIdentifier.new(experiment.name)
        subject.get_experiment(identifier).should eql(experiment)
      end

    end

    context "#get_variant" do

      before(:each) do
        subject.stubs(
          get_experiment: Ostruct.new({
            id: "123",
            name: "X",
            traffic_coverage: 1.0,
            variations: [
              Ostruct.new(
                name: "original",
                weight: 0.5,
                status: "ACTIVE"
              ),
              Ostruct.new(
                name: "variation1",
                weight: 0.5,
                status: "ACTIVE"
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

      it "returns the default if traffic_coverage is 0" do
        subject.get_experiment.stubs(traffic_coverage: 0)
        variant = subject.get_variant("fakename")
        variant.name.should eql("default")
        variant.index.should eql(-1)
      end

    end

  end

end