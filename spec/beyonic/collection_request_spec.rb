# frozen_string_literal: true

describe Beyonic::CollectionRequest do
  before do
    Beyonic.api_key = 'd349087313cc7a6627d77ab61163d4dab6449b4c'
    Beyonic.api_version = 'v1'
    Beyonic::CollectionRequest.instance_variable_set(:@endpoint_url, 'https://staging.beyonic.com/api/collectionrequests')
  end

  let(:payload) do
    {
      phonenumber: '+256772781923',
      currency: 'UGX',
      amount: 3000
    }
  end

  let!(:create_collection_requests) do
    VCR.use_cassette('collection_requests_create') do
      Beyonic::CollectionRequest.create(payload)
    end
  end

  describe '.crate' do
    context 'Success response' do
      subject do
        create_collection_requests
      end

      it {
        is_expected.to have_requested(:post, 'https://staging.beyonic.com/api/collectionrequests').with(
          headers: { 'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_an(Beyonic::CollectionRequest) }

      it { is_expected.to have_attributes(id: create_collection_requests.id, currency: 'UGX') }
    end

    context 'Bad request' do
      subject do
        lambda {
          VCR.use_cassette('collection_requests_invalid_create') do
            Beyonic::CollectionRequest.create(invalid_payload: true)
          end
        }
      end
      it {
        is_expected.to raise_error(Beyonic::AbstractApi::ApiError)
      }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
          VCR.use_cassette('collection_requests_invalid_token_create') do
            Beyonic::CollectionRequest.create(payload)
          end
        }
      end
      it {
        is_expected.to raise_error
      }
    end
  end

  describe '.list' do
    context 'Success response' do
      subject do
        VCR.use_cassette('collection_requests_list') do
          Beyonic::CollectionRequest.list
        end
      end

      it {
        is_expected.to have_requested(:get, 'https://staging.beyonic.com/api/collectionrequests').with(
          headers: { 'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_an(Array) }

      it { is_expected.to all(be_an(Beyonic::CollectionRequest)) }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
          VCR.use_cassette('collection_requests_invalid_token_list') do
            Beyonic::CollectionRequest.list
          end
        }
      end

      it {
        is_expected.to raise_error
      }
    end
  end

  describe '.get' do
    context 'Success response' do
      subject do
        VCR.use_cassette('collection_requests_get') do
          Beyonic::CollectionRequest.get(create_collection_requests.id)
        end
      end

      it {
        is_expected.to have_requested(:get, "https://staging.beyonic.com/api/collectionrequests/#{create_collection_requests.id}").with(
          headers: { 'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_an(Beyonic::CollectionRequest) }

      it { is_expected.to have_attributes(id: create_collection_requests.id, currency: 'UGX') }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
          VCR.use_cassette('collection_requests_invalid_token_get') do
            Beyonic::CollectionRequest.get(create_collection_requests.id)
          end
        }
      end

      it {
        is_expected.to raise_error
      }
    end

    context 'Unauthorized' do
      subject do
        lambda {
          VCR.use_cassette('collection_requests_no_permissions_get') do
            Beyonic::CollectionRequest.get(666)
          end
        }
      end
      it {
        is_expected.to raise_error
      }
    end
  end
end
