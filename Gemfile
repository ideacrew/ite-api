# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0', '>= 7.0.3'
# gem 'sqlite3', '~> 1.4'
# use mongoid as the database
gem 'mongoid', '~> 7.4'

# Use Puma as the app server
gem 'puma', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.7'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# authentication
gem 'devise', '~> 4.8', '>= 4.8.1'
gem 'pundit', '~> 2.2'

# HTTP/REST API client library
# gem 'faraday', '~> 2.2'

# xml parsing
gem 'nokogiri', '~> 1.13', '>= 1.13.6'

# dry gems
gem 'dry-monads', '~> 1.4'
gem 'dry-struct', '~> 1.4'
gem 'dry-transformer', '~> 0.1.1'
gem 'dry-types', '~> 1.5', '>= 1.5.1'
gem 'dry-validation', '~> 1.8'

gem 'oj', '~> 3.13', '>= 3.13.15'

# gem to model and validate FHIR payloads
gem 'fhir_models', '~> 4.2', '>= 4.2.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 2.20'
  gem 'mongoid-rspec', '~> 4.1'
  gem 'pry-byebug', '~> 3.9'
  gem 'rspec-rails', '~> 5.1', '>= 5.1.2'
  # gem 'database_cleaner', '~> 2.0', '>= 2.0.1'
  # awesome print to make the payloads easier to visually parse
  gem 'awesome_print', '~> 1.9', '>= 1.9.2'
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'rubocop', '~> 1.31', '>= 1.31.1'
  gem 'spring'
  gem 'web-console', '~> 4.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
