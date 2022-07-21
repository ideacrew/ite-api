# frozen_string_literal: true

require 'dry-types'

Dry::Types.load_extensions(:maybe)

# Extend Dry Types
module Types
  include Dry.Types
  include Dry::Logic

  TransactionGroups =
      Types::String.enum('admission', 'update/discharge').freeze
end
