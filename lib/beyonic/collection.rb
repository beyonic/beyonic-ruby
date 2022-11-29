# frozen_string_literal: true

require 'ostruct'
class Beyonic::Collection < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource 'collections'
end
