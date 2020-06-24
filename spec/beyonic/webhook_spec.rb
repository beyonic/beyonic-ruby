require 'spec_helper'

describe Beyonic::Webhook do
  before {
    Beyonic.api_key = 'd349087313cc7a6627d77ab61163d4dab6449b4c'
    Beyonic.api_version = 'v1'
    Beyonic::Webhook.instance_variable_set(:@endpoint_url, 'https://staging.beyonic.com/api/webhooks')
  }

  let(:payload) {
    {
      event: 'payment.status.changed',
      target: 'https://my.callback.url/'
    }
  } 

  let!(:create_webhook) {
    VCR.use_cassette('webhooks_create') do
      Beyonic::Webhook.create(payload)
    end
  }
  
  describe '.crate' do
    context 'Success response' do
      subject {
        create_webhook
      }

      it { 
        is_expected.to have_requested(:post, 'https://staging.beyonic.com/api/webhooks').with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Beyonic::Webhook) }

      it { is_expected.to have_attributes(id: create_webhook.id, user: 37) }
    end

    context 'Bad request' do
      subject {
        -> {
          VCR.use_cassette('webhooks_invalid_create') do
            Beyonic::Webhook.create(invalid_payload: true)
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
          VCR.use_cassette('webhooks_invalid_token_create') do
            Beyonic::Webhook.create(payload)
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
        VCR.use_cassette('webhooks_list') do
          Beyonic::Webhook.list
        end
      }

      it { 
        is_expected.to have_requested(:get, 'https://staging.beyonic.com/api/webhooks').with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Array) }
      it { is_expected.to have(2).items }

      it { is_expected.to all(be_an(Beyonic::Webhook)) }
    end

    context 'Unauthorized' do
      before {
        Beyonic.api_key = 'invalid_key'
      }

      subject {
        -> {
        VCR.use_cassette('webhooks_invalid_token_list') do
          Beyonic::Webhook.list
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
        VCR.use_cassette('webhooks_get') do
          Beyonic::Webhook.get(create_webhook.id)
        end
      }

      it { 
        is_expected.to have_requested(:get, "https://staging.beyonic.com/api/webhooks/#{create_webhook.id}").with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Beyonic::Webhook) }

      it { is_expected.to have_attributes(id: create_webhook.id, user: 37) }
    end

    context 'Unauthorized' do
      before {
        Beyonic.api_key = 'invalid_key'
      }

      subject {
        -> {
          VCR.use_cassette('webhooks_invalid_token_get') do
            Beyonic::Webhook.get(create_webhook.id)
          end
        }
      }
      it { 
        is_expected.to raise_error
      }
    end

    context 'Forbidden' do
      subject {
        -> {
          VCR.use_cassette('webhooks_no_permissions_get') do
            Beyonic::Webhook.get(666)
          end
        }
      }
      it { 
        is_expected.to raise_error
      }
    end
  end

  describe '.update' do
    context 'Success response' do
      subject {
        VCR.use_cassette('webhooks_update') do
          Beyonic::Webhook.update(create_webhook.id, target: 'https://my.callback2.url/')
        end
      }

      it { 
        is_expected.to have_requested(:patch, "https://staging.beyonic.com/api/webhooks/#{create_webhook.id}").with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Beyonic::Webhook) }

      it { is_expected.to have_attributes(id: create_webhook.id, target: 'https://my.callback2.url/') }
    end

    context 'Bad request' do
      subject {
        -> {
          VCR.use_cassette('webhooks_invalid_update') do
            Beyonic::Webhook.update(create_webhook.id, event: 'wrongevent')
          end
        }
      }
      it { 
        is_expected.to raise_error(Beyonic::AbstractApi::ApiError)
      }
    end

    context 'Forbidden' do
      subject {
        -> {
          VCR.use_cassette('webhooks_no_permissions_update') do
            Beyonic::Webhook.update(666, target: 'https://my.callback2.url/')
          end
        }
      }

      it { 
        is_expected.to raise_error
      }
    end

    context 'Unauthorized' do
      before {
        Beyonic.api_key = 'invalid_key'
        create_webhook
      }

      subject {
        -> {
          VCR.use_cassette('webhooks_invalid_token_update') do
            Beyonic::Webhook.update(create_webhook.id, target: 'https://my.callback2.url/')
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
      subject { Beyonic::Webhook }

      before {
        allow(subject).to receive(:create)
        subject.new(payload).save
      }     

      it { 
        is_expected.to have_received(:create).with(payload)
      }
    end

    context 'loaded object' do
      subject { 
        Beyonic::Webhook
      }

      before {
        allow(subject).to receive(:update)
        create_webhook.target = 'https://google.com/'
        create_webhook.save
      }

      it { 
        is_expected.to have_received(:update).with(create_webhook.id, hash_including(target: 'https://google.com/'))
      }
    end
  end

  describe '#id=' do
    it { 
      expect{
        create_webhook.id=(4)
      }.to raise_error "Can't change id of existing Beyonic::Webhook"
    }

    it {
      expect {
        create_webhook[:id]=(4)
      }.to raise_error "Can't change id of existing Beyonic::Webhook"
    }

    it {
      expect {
        create_webhook[:target]='foo'
      }.to_not raise_error
    }
  end

  describe '.delete' do
    context 'Success response' do
      subject {
        VCR.use_cassette('webhooks_delete') do
          Beyonic::Webhook.delete(create_webhook.id)
        end
      }

      it { 
        is_expected.to have_requested(:delete, "https://staging.beyonic.com/api/webhooks/#{create_webhook.id}").with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_truthy }

    end

    context 'Forbidden' do
      subject {
        -> {
          VCR.use_cassette('webhooks_no_permissions_delete') do
            Beyonic::Webhook.delete(666)
          end
        }
      }
      it { 
        is_expected.to raise_error
      }
    end

    context 'Unauthorized' do
      before {
        Beyonic.api_key = 'invalid_key'
      }

      subject {
        -> {
          VCR.use_cassette('webhooks_invalid_token_delete') do
            Beyonic::Webhook.delete(create_webhook.id)
          end
        }
      }
      it { 
        is_expected.to raise_error
      }
    end
  end
end