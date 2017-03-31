require 'ostruct'
class Beyonic::Transaction < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource "transactions"
end
