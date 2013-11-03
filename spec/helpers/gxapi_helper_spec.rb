require 'spec_helper'

describe GxapiHelper do

  context "#gxapi_variant_name" do

    it "returns default if the variable is not set" do
      helper.gxapi_variant_name.should eql "default"
    end

    it "returns the name of the vairant if it is set" do
      assign(:variant, stub(:value => stub(:name => "x")))
      helper.gxapi_variant_name.should eql("x")
    end

    it "handles different vairant names" do
      assign(:variantx, stub(:value => stub(:name => "x")))
      helper.gxapi_variant_name(:variantx).should eql("x")
    end

  end

  context "#gxapi_experiment_js" do

    context "with variant set" do

      before(:each) do
        assign(
          :variant,
          stub(
            :value => stub(
              :name => "x",
              :experiment_id => "y",
              :index => 1
            )
          )
        )
      end

      it "adds the javascript src for Google analytics only once
        but does the js call each time the method is called" do

        ret = helper.gxapi_experiment_js + helper.gxapi_experiment_js

        ret.scan(/google\-analytics\.com/).length.should eql(1)
        ret.scan(/setChosenVariation/).length.should eql(2)

      end

      it "should add the domain if an option is passed" do
        ret = helper.gxapi_experiment_js(:domain => ".example.com")
        ret.should =~ /setDomainName/
      end

    end

    it "should not do anything if the instance var is not defined" do
      helper.gxapi_experiment_js.should eql("")
    end

  end

end