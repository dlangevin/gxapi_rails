require 'spec_helper'

module Gxapi

  feature 'Gxapi Integration with Rails' do

    let(:stub_experiments) do

    end

    before(:all) do
      stub_experiments = [
        Ostruct.new(
          id: '123',
          name: 'Untitled experiment',
          traffic_coverage: 1.0,
          variations: [
            Ostruct.new(
              name: 'original',
              weight: 0.5,
              status: 'ACTIVE'
            ),
            Ostruct.new(
              name: 'test',
              weight: 0.5,
              status: 'ACTIVE'
            )
          ]
        )
      ]
      GoogleAnalytics.any_instance.stubs(:get_experiments).returns(stub_experiments)
      Gxapi.reload_experiments
    end

    context 'GET /posts' do

      it 'renders the google analytics data for a user' do

        visit posts_path

        expect(page.body).to match(/cxApi\.setChosenVariation/)

      end

      it 'renders the content expected when a parameter is passed in
        for the variant value' do

        visit posts_path(variant: 'fake_var')

        expect(page.body).to have_content('Fake Var Version')

      end

    end

  end

end
