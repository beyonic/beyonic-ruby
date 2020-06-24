require 'spec_helper'

describe Beyonic::Collection do
  before do
    Beyonic.api_key = 'd349087313cc7a6627d77ab61163d4dab6449b4c'
    Beyonic.api_version = 'v1'
    Beyonic::Collection.instance_variable_set(:@endpoint_url, 'https://staging.beyonic.com/api/collections')
  end
  

  describe '.list' do
    context 'Success response' do
      subject do
        VCR.use_cassette('collections_list') do
          Beyonic::Collection.list
        end
      end

      it { 
        is_expected.to have_requested(:get, 'https://staging.beyonic.com/api/collections').with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Array) }
      it { is_expected.to have(1).items }

      it { is_expected.to all(be_an(Beyonic::Collection)) }
    end

    context 'Phonenumber search' do
      subject do
        VCR.use_cassette('collections_search') do
          Beyonic::Collection.list(phonenumber: '+254727843600')
        end
      end

      it { 
        is_expected.to have_requested(:get, 'https://staging.beyonic.com/api/collections?phonenumber=%2B254727843600').with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Array) }

      it { is_expected.to have(1).items }

      it { is_expected.to all(be_an(Beyonic::Collection)) }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
          VCR.use_cassette('collections_invalid_token_list') do
            Beyonic::Collection.list
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
        VCR.use_cassette('collections_get') do
          Beyonic::Collection.get(1)
        end
      end

      it { 
        is_expected.to have_requested(:get, 'https://staging.beyonic.com/api/collections/1').with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Beyonic::Collection) }

      it { is_expected.to have_attributes(id: 1, status: 'successful') }
    end

    context 'Unauthorized' do
      before do 
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
          VCR.use_cassette('collections_invalid_token_get') do
            Beyonic::Collection.get(1)
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
          VCR.use_cassette('collections_no_permissions_get') do
            Beyonic::Collection.get(666)
          end
        }
      end
      it { 
        is_expected.to raise_error
      }
    end
  end

  describe '.claim' do
    
    context 'by Phonenumber' do
      subject do
        VCR.use_cassette('collections_claim') do
          Beyonic::Collection.claim(200, '+254727843600', nil)
        end
      end

      it { 
        is_expected.to have_requested(:get, 'https://staging.beyonic.com/api/collections?amount=200&claim=true&phonenumber=%2B254727843600&remote_transaction_id').with(
            headers: {'Authorization' => 'Token d349087313cc7a6627d77ab61163d4dab6449b4c', 'Beyonic-Version' => 'v1'}
          )
      }
      it { is_expected.to be_an(Array) }

      it { is_expected.to have(0).items }

      it { is_expected.to all(be_an(Beyonic::Collection)) }
    end

    context 'Unauthorized' do
      before do
        Beyonic.api_key = 'invalid_key'
      end

      subject do
        lambda {
          VCR.use_cassette('collections_invalid_token_claim') do
            Beyonic::Collection.claim(200, '+254727843600', nil)
          end
        }
      end

      it { 
        is_expected.to raise_error
      }
    end
  end
end
