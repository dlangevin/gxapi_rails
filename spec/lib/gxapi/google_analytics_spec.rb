require 'spec_helper'

module Gxapi

  describe GoogleAnalytics do

    before(:each) do
      Gxapi.cache.clear
      stub_request(:post, /.*accounts.google.com\/o\/oauth2\/token/)
        .to_return(
          status: 200,
          body: JSON.unparse({ access_token: 'foo' }),
          headers: { 'Content-Type' => 'application/json'}
        )
      stub_request(:get, /discovery\/v1\/apis\/analytics\/v3\/rest/)
        .to_return(File.new("spec/fixtures/analytics_discovery.json"))
    end

    context "#get_experiments" do
      before do
        stub_request(:get, /googleapis.*experiments/)
          .to_return(
            status: 200,
            body: JSON.unparse(
              data: {
                items: [
                  {
                    id: "123",
                    name: "exp1",
                    traffic_coverage: 1.0,
                    variations: []
                  },
                  {
                    id: "234",
                    name: "exp2",
                    traffic_coverage: 1.0,
                    variations: []
                  }
                ]
              }
            ),
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "gets a list of experiments" do
        experiments = subject.get_experiments
        expect(experiments.first).to be_a(Gxapi::Ostruct)
      end

    end

    context "#get_experiment" do
      before do
        stub_request(:get, /googleapis.*experiments/)
          .to_return(
            status: 200,
            body: JSON.unparse(
              data: {
                items: [
                  {
                    id: "123",
                    name: "exp1",
                    traffic_coverage: 1.0,
                    variations: []
                  },
                  {
                    id: "234",
                    name: "exp2",
                    traffic_coverage: 1.0,
                    variations: []
                  }
                ]
              }
            ),
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "should filter by name" do
        experiment = subject.get_experiments.first
        identifier = GxApi::ExperimentIdentifier.new(experiment.name)
        expect(subject.get_experiment(identifier)).to eql(experiment)
      end

    end

    context "#get_variant" do

      before do
        stub_request(:get, /googleapis.*experiments/)
          .to_return(
            status: 200,
            body: JSON.unparse(
              data: {
                items: [
                  {
                    id: "234",
                    name: "fakename",
                    traffic_coverage: 1.0,
                    variations: [
                      {
                        name: "original",
                        weight: 0.5,
                        status: "ACTIVE"
                      },
                      {
                        name: "variation1",
                        weight: 0.5,
                        status: "ACTIVE"
                      }
                    ]
                  },
                  {
                    id: "456",
                    name: "zerocoverage",
                    traffic_coverage: 0.0,
                    variations: [
                      {
                        name: "original",
                        weight: 0.5,
                        status: "ACTIVE"
                      },
                      {
                        name: "variation1",
                        weight: 0.5,
                        status: "ACTIVE"
                      }
                    ]
                  }
                ]
              }
            ),
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns a variant determined by weight" do
        variant = subject.get_variant(
          GxApi::ExperimentIdentifier.new("fakename")
        )
        expect(["original", "variation1"]).to include variant.name
        expect([0, 1]).to include variant.index
      end

      it "returns the default if traffic_coverage is 0" do
        variant = subject.get_variant(
          GxApi::ExperimentIdentifier.new("zerocoverage")
        )
        expect(variant.name).to eql("default")
        expect(variant.index).to eql(-1)
      end

    end

  end

end
