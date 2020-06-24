require 'spec_helper'

describe Beyonic::Account do
  before do
    Beyonic.api_key = 'd349087313cc7a6627d77ab61163d4dab6449b4c'
    Beyonic.api_version = 'v1'
    API_ENDPOINT = 'https://staging.beyonic.com/api/accounts'
    Beyonic::Account.instance_variable_set(:@endpoint_url, API_ENDPOINT)
  end

  describe '.list' do
    context 'Success response' do
      subject do
        VCR.use_cassette('accounts_list') do
          Beyonic::Account.list
        end
      end

      it {
        is_expected.to have_requested(:get, "#{API_ENDPOINT}").with(
            headers: {'Authorization' => "Token #{Beyonic.api_key}", 'Beyonic-Version' => Beyonic.api_version}
          )
      }
      it { is_expected.to be_an(Array) }

      it { is_expected.to all(be_an(Beyonic::Account)) }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
          VCR.use_cassette('accounts_invalid_token_list') do
            Beyonic::Account.list
          end
        }
      end

      it {
        is_expected.to raise_error
      }
    end
  end
end
