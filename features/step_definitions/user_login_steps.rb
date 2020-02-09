require 'capybara'
Given(/^the User is not logged in$/) do
  current_user = nil
end

When(/^the User opens the application$/) do
  visit "/"
end

Then(/^the User should be redirected to the Login page$/) do
  pending # Write code here that turns the phrase above into concrete actions
end
