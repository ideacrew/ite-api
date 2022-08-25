# frozen_string_literal: true

module Entities
  module Api
    module V1
      # entity to define the clinical info for use in payload validation
      class ClinicalInfo < Dry::Struct
        # GAF/CGAS Score – Optional
        attribute :gaf_score, Types::String.optional.meta(omittable: true)
        # SMI/SED Status
        attribute :smi_sed, Types::String.optional.meta(omittable: true)
        # Co-occurring substance abuse and mental health problems
        attribute :co_occurring_sud_mh, Types::String.optional.meta(omittable: true)
        # Medication-Assisted Opioid Therapy
        attribute :opioid_therapy, Types::String.optional.meta(omittable: true)
        attribute :substance_problems, Types::Array.of(SubstanceProblem)
        attribute :sud_diagnostic_codes, Types::Array.of(Types::String)
        attribute :mh_diagnostic_codes, Types::Array.of(Types::String)
        attribute :non_bh_dx1, Types::String.optional.meta(omittable: true)
        attribute :non_bh_dx2, Types::String.optional.meta(omittable: true)
        attribute :non_bh_dx3, Types::String.optional.meta(omittable: true)
      end
    end
  end
end
