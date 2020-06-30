# frozen_string_literal: true

require 'ostruct'
class Beyonic::Payment < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource 'payments'
end
