require 'spec_helper'

module Gxapi

  describe 'Gxapi Integration with Rails' do

    before(:all) do
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