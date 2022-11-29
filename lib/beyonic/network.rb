# frozen_string_literal: true

require 'ostruct'
class Beyonic::Network < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource 'networks'
end
