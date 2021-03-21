# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# use passenger as application server

gem 'passenger', '>= 5.0.25', require: 'phusion_passenger/rack_handler'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'


# add highline gem to bundle for command line stuff for now
# only needed for experimenting with csv conversion and formatting.
  gem 'highline'


# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# use Devise for User authentication
gem 'devise'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails', '~> 3.8'

  gem 'cucumber-rails', require: false
  gem 'spring-commands-cucumber'
  gem 'spring-commands-rspec'
  # Capybara, the library that allows us to interact with the browser using Ruby
  gem 'capybara'

  # This gem helps Capybara interact with the web browser.
  gem 'webdrivers'

  # Factory Bot for test data
  gem 'factory_bot_rails'

  # Faker for faking test data in factories
  gem 'faker'

  # database-cleaner to clean up test data
  gem 'database_cleaner'

  # add launchy to automatically launch browser
  gem 'launchy'

  # code style analysis with rubocop
  gem 'guard-rubocop'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard'
  gem 'guard-brakeman'
  gem 'guard-bundler', require: false
  gem 'guard-cucumber'
  gem 'guard-delayed'
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'guard-passenger'
  gem 'guard-rspec', require: false
  gem 'guard-spring'
  gem 'rack-livereload'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
group :test do
  gem 'simplecov', require: false
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
