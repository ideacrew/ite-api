# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe Api::V1::ExtractPolicy do
  let(:user) { double { 'User' } }
  context 'ingest?' do
    it 'when user is dbh' do
      allow(user).to receive(:provider?).and_return(true)
      expect(described_class.new(user, nil).ingest?).to eq true
    end

    it 'when user is with dual role' do
      allow(user).to receive(:provider?).and_return(false)
      expect(described_class.new(user, nil).ingest?).to eq false
    end
  end

  context 'show?' do
    it 'when user is dbh' do
      allow(user).to receive(:dbh_user?).and_return(false)
      allow(user).to receive(:provider?).and_return(true)
      expect(described_class.new(user, nil).show?).to eq true
    end

    it 'when user is with dual role' do
      allow(user).to receive(:provider?).and_return(true)
      allow(user).to receive(:dbh_user?).and_return(true)
      expect(described_class.new(user, nil).show?).to eq true
    end

    it 'when user is dbh' do
      allow(user).to receive(:provider?).and_return(false)
      allow(user).to receive(:dbh_user?).and_return(true)
      expect(described_class.new(user, nil).show?).to eq true
    end
  end

  context 'show_dbh?' do
    it 'when user is dbh' do
      allow(user).to receive(:dbh_user?).and_return(false)
      allow(user).to receive(:provider?).and_return(true)
      expect(described_class.new(user, nil).show_dbh?).to eq false
    end

    it 'when user is with dual role' do
      allow(user).to receive(:provider?).and_return(true)
      allow(user).to receive(:dbh_user?).and_return(true)
      expect(described_class.new(user, nil).show_dbh?).to eq true
    end

    it 'when user is dbh' do
      allow(user).to receive(:provider?).and_return(false)
      allow(user).to receive(:dbh_user?).and_return(true)
      expect(described_class.new(user, nil).show_dbh?).to eq true
    end
  end

  context 'show_provider?' do
    it 'when user is dbh' do
      allow(user).to receive(:provider?).and_return(true)
      expect(described_class.new(user, nil).show_provider?).to eq true
    end

    it 'when user is with dual role' do
      allow(user).to receive(:provider?).and_return(false)
      expect(described_class.new(user, nil).show_provider?).to eq false
    end
  end
end
