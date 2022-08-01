# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ProvidersController do
  describe 'routing' do
    it 'route to Provider#index' do
      expect(get('/api/v1/providers')).to route_to('api/v1/providers#index')
    end

    it 'route to Provider#create' do
      expect(post('/api/v1/providers')).to route_to('api/v1/providers#create')
    end

    it 'route to Provider#update' do
      expect(put('/api/v1/providers/1')).to route_to('api/v1/providers#update', id: '1')
    end
  end
end
