# frozen_string_literal: true

module Api
  module V1
    # entity to define the clinical info for use in payload validation
    class ClinicalInfo < Dry::Struct
      # GAF/CGAS Score – Optional
      # SMI/SED Status
      # Co-occurring substance abuse and mental health problems
      # Medication-Assisted Opioid Therapy
      attribute :substance_problems, Types::Array.of(SubstanceProblem)
      attribute :sud_diagnostic_codes, Types::Array.of(Types::String)
      attribute :mh_diagnostic_codes, Types::Array.of(Types::String)
      # Substance Problem - Primary
      # Substance Problem - Secondary
      # Substance Problem - Tertiary
      # Detailed Drug Code - Primary/Secondary/Tertiary
      # Age at First Use - Primary
      # Age at First Use - Secondary
      # Age at First Use - Tertiary
      # Frequency of Use - Primary
      # Frequency of Use - Secondary
      # Frequency of Use - Tertiary
      # Route of Administration - Primary
      # Route of Administration - Secondary
      # Route of Administration - Tertiary
    end
  end
end
