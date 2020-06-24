require 'ostruct'
class Beyonic::Collection < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource 'collections'
end
