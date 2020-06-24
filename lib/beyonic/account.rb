require 'ostruct'
class Beyonic::Account < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource 'accounts'
end
