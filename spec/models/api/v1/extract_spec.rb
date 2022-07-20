# frozen_string_literal: true

require 'rails_helper'
# require 'types'

RSpec.describe Api::V1::Extract, type: :model do

  let(:extract_params) do 
    {"provider_identifier": "all_fields",
    "file_type": "Admission",
    "coverage_start": Date.new(2022, 01, 01),
    "coverage_end": Date.new(2022, 02, 01),
    "npi": "randomId"
    }
  end

  context 'with a valid payload' do
    context 'all values filled in' do
      before do
        @extract = described_class.create(extract_params)
      end

      it 'will create an extract' do
        expect(@extract.class).to eq(described_class)
      end

      it 'will have a coverage range' do
        binding.pry
        expect(@extract.coverage_range).to eq(Date.new(2022, 01, 01)..Date.new(2022, 02, 01))
      end
    end
  end

  context 'with a invalid payload' do
    context 'without a provider identifier' do
      it 'will not create an extract' do
        extract_params[:provider_identifier] = nil
        extract = described_class.new(extract_params)
        expect(extract.save).to eq false
      end
    end
  end

end