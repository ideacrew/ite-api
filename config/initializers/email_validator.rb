# frozen_string_literal: true

EmailValidator.default_options.merge!({ allow_nil: false, require_fqdn: true, mode: :strict }) if defined?(EmailValidator)
