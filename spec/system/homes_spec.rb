require 'rails_helper'
RSpec.describe "Homes", type: :system do
  before do
    driven_by(:rack_test)
  end
  describe 'authenticated access only' do
    # setup a rodauth local variable
    rodauth = Rodauth::Rails.rodauth

    it 'redirects user to login page if user is not authenticated' do
      # if a user is currently authenticated, log this user out.
      rodauth.logout
      page = visit root_path
      expect(page).to have_content 'Test'
      #redirect_to(rodauth.login_path)
    end
  end

end
