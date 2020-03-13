Feature: User Login
  Forenlims should only be accessible by logged in users.

Scenario: User is not logged in
  Given the User is not logged in
  When the User opens the application
  Then the User should be redirected to the Login page
