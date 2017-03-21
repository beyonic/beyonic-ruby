module Beyonic

  require "rest-client"
  require "oj"

  # Uncomment this if you are testing on your server and you want to bypass SSL checks.
  # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  def self.api_key=(key)
    @api_key = key
  end

  def self.api_key
    @api_key
  end

  def self.api_version=(version)
    @api_version = version
  end

  def self.api_version
    @api_version
  end

  def self.endpoint_base
    "https://app.beyonic.com/api/"
  end

end

require "beyonic/version"
require "beyonic/abstract_api"
require "beyonic/payment"
require "beyonic/webhook"
require "beyonic/collection"
require "beyonic/collection_request"
require "beyonic/account"
require "beyonic/contact"
require "beyonic/transaction"
