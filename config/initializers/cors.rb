# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

domains = [
  'dbh-ite.com',
  'github.dev',
  'githubpreview.dev',
  'preview.app.github.dev'
].join('|')

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/api/v1/extracts/ingest', headers: :any, methods: %i[post]
    resource '/session', headers: :any, methods: %i[post delete]
  end

  allow do
    if Rails.env.development?
      origins(%r{^(http?://)?localhost(:\d+)?/?$})
    else
      origins(%r{^https://(|[^.]+\.)(#{domains})/?$})
    end

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head]
  end
end
