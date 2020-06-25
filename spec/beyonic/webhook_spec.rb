require 'spec_helper'

describe Beyonic::Webhook do
  before do
    Beyonic.api_key = 'd349087313cc7a6627d77ab61163d4dab6449b4c'
    Beyonic.api_version = 'v1'
    Beyonic::Webhook.instance_variable_set(:@endpoint_url, 'https://staging.beyonic.com/api/webhooks')
  end

  let(:payload) do
    {
      event: 'payment.status.changed',
      target: 'https://my.callback.url/'
    }
  end

  let!(:create_webhook) do
    VCR.use_cassette('webhooks_create') do
      Beyonic::Webhook.create(payload)
    end
  end

  describe '.crate' do
    context 'Success response' do
      subject do
        create_webhook
      end

      it {
        is_expected.to have_requested(:post, 'https://staging.beyonic.com/api/webhooks').with(
          headers: { 'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_an(Beyonic::Webhook) }

      it { is_expected.to have_attributes(id: create_webhook.id, user: 37) }
    end

    context 'Bad request' do
      subject do
        lambda {
          VCR.use_cassette('webhooks_invalid_create') do
            Beyonic::Webhook.create(invalid_payload: true)
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
          VCR.use_cassette('webhooks_invalid_token_create') do
            Beyonic::Webhook.create(payload)
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
        VCR.use_cassette('webhooks_list') do
          Beyonic::Webhook.list
        end
      end

      it {
        is_expected.to have_requested(:get, 'https://staging.beyonic.com/api/webhooks').with(
          headers: { 'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_an(Array) }
      it { is_expected.to have(2).items }

      it { is_expected.to all(be_an(Beyonic::Webhook)) }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
        VCR.use_cassette('webhooks_invalid_token_list') do
          Beyonic::Webhook.list
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
        VCR.use_cassette('webhooks_get') do
          Beyonic::Webhook.get(create_webhook.id)
        end
      end

      it {
        is_expected.to have_requested(:get, "https://staging.beyonic.com/api/webhooks/#{create_webhook.id}").with(
          headers: { 'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_an(Beyonic::Webhook) }

      it { is_expected.to have_attributes(id: create_webhook.id, user: 37) }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
          VCR.use_cassette('webhooks_invalid_token_get') do
            Beyonic::Webhook.get(create_webhook.id)
          end
        }
      end
      it {
        is_expected.to raise_error
      }
    end

    context 'Forbidden' do
      subject do
        lambda {
          VCR.use_cassette('webhooks_no_permissions_get') do
            Beyonic::Webhook.get(666)
          end
        }
      end
      it {
        is_expected.to raise_error
      }
    end
  end

  describe '.update' do
    context 'Success response' do
      subject do
        VCR.use_cassette('webhooks_update') do
          Beyonic::Webhook.update(create_webhook.id, target: 'https://my.callback2.url/')
        end
      end

      it {
        is_expected.to have_requested(:patch, "https://staging.beyonic.com/api/webhooks/#{create_webhook.id}").with(
          headers: { 'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_an(Beyonic::Webhook) }

      it { is_expected.to have_attributes(id: create_webhook.id, target: 'https://my.callback2.url/') }
    end

    context 'Bad request' do
      subject do
        lambda {
          VCR.use_cassette('webhooks_invalid_update') do
            Beyonic::Webhook.update(create_webhook.id, event: 'wrongevent')
          end
        }
      end
      it {
        is_expected.to raise_error(Beyonic::AbstractApi::ApiError)
      }
    end

    context 'Forbidden' do
      subject do
        lambda {
          VCR.use_cassette('webhooks_no_permissions_update') do
            Beyonic::Webhook.update(666, target: 'https://my.callback2.url/')
          end
        }
      end

      it {
        is_expected.to raise_error
      }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
        create_webhook
      end

      subject do
        lambda {
          VCR.use_cassette('webhooks_invalid_token_update') do
            Beyonic::Webhook.update(create_webhook.id, target: 'https://my.callback2.url/')
          end
        }
      end
      it {
        is_expected.to raise_error
      }
    end
  end

  describe '#save' do
    context 'new object' do
      subject { Beyonic::Webhook }

      before do
        allow(subject).to receive(:create)
        subject.new(payload).save
      end

      it {
        is_expected.to have_received(:create).with(payload)
      }
    end

    context 'loaded object' do
      subject do
        Beyonic::Webhook
      end

      before do
        allow(subject).to receive(:update)
        create_webhook.target = 'https://google.com/'
        create_webhook.save
      end

      it {
        is_expected.to have_received(:update).with(create_webhook.id, hash_including(target: 'https://google.com/'))
      }
    end
  end

  describe '#id=' do
    it {
      expect do
        create_webhook.id = 4
      end.to raise_error "Can't change id of existing Beyonic::Webhook"
    }

    it {
      expect do
        create_webhook[:id] = 4
      end.to raise_error "Can't change id of existing Beyonic::Webhook"
    }

    it {
      expect do
        create_webhook[:target] = 'foo'
      end.to_not raise_error
    }
  end

  describe '.delete' do
    context 'Success response' do
      subject do
        VCR.use_cassette('webhooks_delete') do
          Beyonic::Webhook.delete(create_webhook.id)
        end
      end

      it {
        is_expected.to have_requested(:delete, "https://staging.beyonic.com/api/webhooks/#{create_webhook.id}").with(
          headers: { 'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1' }
        )
      }
      it { is_expected.to be_truthy }
    end

    context 'Forbidden' do
      subject do
        lambda {
          VCR.use_cassette('webhooks_no_permissions_delete') do
            Beyonic::Webhook.delete(666)
          end
        }
      end
      it {
        is_expected.to raise_error
      }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
          VCR.use_cassette('webhooks_invalid_token_delete') do
            Beyonic::Webhook.delete(create_webhook.id)
          end
        }
      end
      it {
        is_expected.to raise_error
      }
    end
  end
end
