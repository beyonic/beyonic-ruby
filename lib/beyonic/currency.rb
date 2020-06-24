require 'ostruct'
class Beyonic::Currency < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource 'currencies'
end
