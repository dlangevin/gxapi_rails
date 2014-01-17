require 'spec_helper'

module GxApi

  describe ExperimentIdentifier do

    subject {
      ExperimentIdentifier.new("Test Test")
    }

    context "Generic Methods" do

      context "#to_key" do

        it "turns its value into a string for a cache key" do
          expect(subject.to_key).to eql("test_test")
        end

      end

    end


    context "IdIdentifier" do

      subject {
        ExperimentIdentifier.new(id: id)
      }

      let(:id) {
        "123"
      }

      context '#matches_experiment?' do

        it 'matches by id' do
          experiment = stub(id: id)
          expect(subject.matches_experiment?(experiment)).to be_true
        end

      end

      context '#value' do

        it 'returns the id as its value' do
          expect(subject.value).to eq(id)
        end

      end



    end


    context "NameIdentifier" do

      subject {
        ExperimentIdentifier.new(name)
      }

      let(:name) {
        "123"
      }

      context '#matches_experiment?' do

        it 'matches by name' do
          experiment = stub(name: name)
          expect(subject.matches_experiment?(experiment)).to be_true
        end

      end

      context '#value' do

        it 'returns the id as its value' do
          expect(subject.value).to eq(name)
        end

      end

    end

  end

end