# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ExtractsController do
  describe 'routing' do
    it 'route to Extract#ingest' do
      expect(post('/api/v1/extracts/ingest')).to route_to('api/v1/extracts#ingest')
    end

    it 'route to Extract#index' do
      expect(get('/api/v1/extracts')).to route_to('api/v1/extracts#index')
    end
  end
end
