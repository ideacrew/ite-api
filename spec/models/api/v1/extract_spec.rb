# frozen_string_literal: true

require 'rails_helper'
# require 'types'

RSpec.describe Api::V1::Extract, type: :model, dbclean: :around_each do
  let(:extract_params) do
    { "provider_gateway_identifier": 'all_fields',
      "coverage_start": Date.new(2022, 0o1, 0o1),
      "coverage_end": Date.new(2022, 0o1, 31) }
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
        expect(@extract.coverage_range.count).to eq(31)
      end

      it 'will have a record critical error count' do
        expect(@extract.record_critical_errors_count).to eq(0)
      end
      it 'will have a record fatal error count' do
        expect(@extract.record_fatal_errors_count).to eq(0)
      end
      it 'will have a record warning count' do
        expect(@extract.record_warning_count).to eq(0)
      end
      it 'will have a list_view that contains various fields' do
        expect(@extract.list_view[:submission_date]).to eq(@extract.created_at)
        expect(@extract.list_view[:number_of_records]).to eq(@extract.record_count)
      end
    end
  end

  context 'with a invalid payload' do
    context 'without a provider identifier' do
      it 'will not create an extract' do
        extract_params[:provider_gateway_identifier] = nil
        extract = described_class.new(extract_params)
        expect(extract.save).to eq false
      end
    end
  end
end
