# frozen_string_literal: true

module Api
  module V1
    # entity to define a substance problem for use in payload validation
    class SubstanceProblem < Dry::Struct
      # level (primary/secondar/tertiary)
      # Detailed Drug Code
      # Age at First Use
      # Frequency of Use
      # Route of Administration
    end
  end
end
