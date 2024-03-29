# frozen_string_literal: true

require 'spec_helper'
# require 'email_validator'
require './app/domain/validators/api/v1/email_contract'

RSpec.describe ::Validators::Api::V1::EmailContract, dbclean: :around_each do
  let(:all_params) do
    {
      address: 'test@test.com'
    }
  end

  context 'invalid parameters' do
    context 'invalid email address' do
      it 'should fail if more than 5 characters' do
        all_params.merge!(address: 'dfkjvhjfdh')
        expect(subject.call(all_params).errors.to_h[:address]).to eq(['invalid email address'])
      end
    end
  end

  context 'valid parameters' do
    context 'with all parameters' do
      it 'should pass validation' do
        result = subject.call(all_params)
        expect(result.success?).to be_truthy
      end
    end
  end
end
