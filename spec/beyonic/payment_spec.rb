require 'spec_helper'

describe Beyonic::Payment do
  before {
    Beyonic.api_key = 'd349087313cc7a6627d77ab61163d4dab6449b4c'
    Beyonic.api_version = 'v1'
    Beyonic::Payment.instance_variable_set(:@endpoint_url, 'https://staging.beyonic.com/api/payments')
  }

  let(:payload) {
    {
      phonenumber: '+256773712831',
      amount: '100.2',
      currency: 'UGX',
      description: 'Per diem payment',
      payment_type: 'money',
      callback_url: 'https://my.website/payments/callback',
      metadata: "{'id': '1234', 'name': 'Lucy'}"
    }
  }

  let!(:create_payment) {
    VCR.use_cassette('payments_create') do
      Beyonic::Payment.create(payload)
    end
  }
  
  describe '.crate' do
    context 'Success response' do
      subject {
        create_payment
      }

      it { 
        is_expected.to have_requested(:post, 'https://staging.beyonic.com/api/payments').with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Beyonic::Payment) }

      it { is_expected.to have_attributes(id: create_payment.id, state: 'new') }
    end

    context 'Bad request' do
      subject {
        -> {
          VCR.use_cassette('payments_invalid_create') do
            Beyonic::Payment.create(invalid_payload: true)
          end
        }
      }
      it { 
        is_expected.to raise_error(Beyonic::AbstractApi::ApiError)
      }
    end

    context 'Unauthorized' do
      before { 
        Beyonic.api_key = 'invalid_key'
      }

      subject {
        -> {
          VCR.use_cassette('payments_invalid_token_create') do
            Beyonic::Payment.create(payload)
          end
        }
      }
      it { 
        is_expected.to raise_error
      }
    end

  end

  describe '.list' do
    context 'Success response' do
      subject {
        VCR.use_cassette('payments_list') do
          Beyonic::Payment.list
        end
      }

      it { 
        is_expected.to have_requested(:get, 'https://staging.beyonic.com/api/payments').with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Array) }

      it { is_expected.to all(be_an(Beyonic::Payment)) }
    end

    context 'Unauthorized' do
      before {
        Beyonic.api_key = 'invalid_key'
      }

      subject {
        -> {
          VCR.use_cassette('payments_invalid_token_list') do
            Beyonic::Payment.list
          end
        }
      }

      it { 
        is_expected.to raise_error
      }
    end
  end

  describe '.get' do
    context 'Success response' do
      subject {
        VCR.use_cassette('payments_get') do
          Beyonic::Payment.get(create_payment.id)
        end
      }

      it { 
        is_expected.to have_requested(:get, "https://staging.beyonic.com/api/payments/#{create_payment.id}").with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Beyonic::Payment) }

      it { is_expected.to have_attributes(id: create_payment.id, state: 'new') }
    end

    context 'Unauthorized' do
      before { 
        Beyonic.api_key = 'invalid_key'
      }

      subject {
        -> {
          VCR.use_cassette('payments_invalid_token_get') do
            Beyonic::Payment.get(create_payment.id)
          end
        }
      }

      it { 
        is_expected.to raise_error
      }
    end

    context 'Unauthorized' do
      subject {
        -> {
          VCR.use_cassette('payments_no_permissions_get') do
            Beyonic::Payment.get(666)
          end
        }
      }
      it { 
        is_expected.to raise_error
      }
    end
  end

  describe '#save' do
    context 'new object' do
      subject { Beyonic::Payment }

      before {
        allow(subject).to receive(:create)
        subject.new(payload).save
      }     

      it { 
        is_expected.to have_received(:create).with(payload)
      }
    end

    context 'loaded object' do
      subject { Beyonic::Payment }
      before { 

        allow(subject).to receive(:update)

        create_payment.description = 'foo'
        create_payment.save
      }

      it { 
        is_expected.to have_received(:update).with(create_payment.id, hash_including(description: 'foo'))
      }
    end
  end
end
