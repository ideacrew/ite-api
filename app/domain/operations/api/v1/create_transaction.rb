# frozen_string_literal: true

module Operations
  module Api
    module V1
      # operation to create transaction
      class CreateTransaction
        def call(params)
          validated_extract = yield validate_extract(params)
          extract_entity = yield create_entity(validated_extract)
          extract = yield create_extract(extract_entity)
          _transactions = create_transactions(extract, params)
        end
      end
    end
  end
end
