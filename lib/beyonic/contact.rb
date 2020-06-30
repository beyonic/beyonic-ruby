# frozen_string_literal: true

require 'ostruct'
class Beyonic::Contact < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource 'contacts'
end
