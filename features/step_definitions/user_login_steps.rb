Given(/^the User is not logged in$/) do
  current_user = nil
  visit('/users/sign_out') # ensure no user is logged in.
end

When(/^the User opens the application$/) do
  visit '/'
end

Then(/^the User should be redirected to the Login page$/) do
  expect(page).to have_button('Log in')
end
