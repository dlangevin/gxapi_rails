require 'spec_helper'

describe MoonaHelper do

  context "#moona_variant_name" do

    it "returns default if the variable is not set" do
      helper.moona_variant_name.should eql "default"
    end

    it "returns the name of the vairant if it is set" do
      assign(:variant, stub(:value => stub(:name => "x")))
      helper.moona_variant_name.should eql("x")
    end

    it "handles different vairant names" do
      assign(:variantx, stub(:value => stub(:name => "x")))
      helper.moona_variant_name(:variantx).should eql("x")
    end

    it "handles params for the variant" do
      helper.stubs(:params => {:variant => "test"})
      helper.moona_variant_name.should eql("test")
    end

  end

  context "#moona_experiment_js" do

    it "adds the javascript src for Google analytics only once
      but does the js call each time the method is called" do

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

      ret = helper.moona_experiment_js + helper.moona_experiment_js

      ret.scan(/google\-analytics\.com/).length.should eql(1)
      ret.scan(/setChosenVariation/).length.should eql(2)

    end

    it "should not do anything if the instance var is not defined" do
      helper.moona_experiment_js.should eql("")
    end

  end

end