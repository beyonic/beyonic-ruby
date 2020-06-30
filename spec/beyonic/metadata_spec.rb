# frozen_string_literal: true

require 'spec_helper'

describe Beyonic::CollectionRequest do
  before do
    Beyonic.api_key = 'c4269a8029e8a7c5659d3cb7829ce1d7319b4689'
    Beyonic.api_version = 'v1'
    Beyonic::CollectionRequest.instance_variable_set(:@endpoint_url, 'https://staging.beyonic.com/api/collectionrequests')
  end

  let(:array_notation_payload) do
    {
      phonenumber: '+40715441309',
      currency: 'BXC',
      amount: 3000,
      metadata: { "my_id": '123ASDAsd123' }
    }
  end

  let(:dot_notation_payload) do
    {
      phonenumber: '+40715441309',
      currency: 'BXC',
      amount: 3000,
      'metadata.my_id': '123ASDAsd123'
    }
  end

  describe '.create_array_notation' do
    let!(:metadata_array_notation_request) do
      VCR.use_cassette('metadata_create_requests_array_notation') do
        Beyonic::CollectionRequest.create(array_notation_payload)
      end
    end
    context 'Success response' do
      subject do
        metadata_array_notation_request
      end

      it {
        is_expected.to have_requested(:post, 'https://staging.beyonic.com/api/collectionrequests').with(
          headers: { 'Authorization' => 'Token c4269a8029e8a7c5659d3cb7829ce1d7319b4689', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_an(Beyonic::CollectionRequest) }
      it { is_expected.to have_attributes('metadata': metadata_array_notation_request.metadata, currency: 'BXC') }
    end
  end

  describe '.create_dot_notation' do
    let!(:metadata_dot_notation_request) do
      VCR.use_cassette('metadata_create_requests_dot_notation') do
        Beyonic::CollectionRequest.create(dot_notation_payload)
      end
    end
    context 'Success response' do
      subject do
        metadata_dot_notation_request
      end

      it {
        is_expected.to have_requested(:post, 'https://staging.beyonic.com/api/collectionrequests').with(
          headers: { 'Authorization' => 'Token c4269a8029e8a7c5659d3cb7829ce1d7319b4689', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_an(Beyonic::CollectionRequest) }
      it { is_expected.to have_attributes('metadata': metadata_dot_notation_request.metadata, currency: 'BXC') }
    end
  end
end
