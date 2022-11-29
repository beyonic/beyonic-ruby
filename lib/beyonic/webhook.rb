# frozen_string_literal: true

require 'ostruct'
class Beyonic::Webhook < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource 'webhooks'
end
