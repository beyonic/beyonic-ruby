require 'ostruct'
class Beyonic::CollectionRequest < OpenStruct
  include Beyonic::AbstractApi
  set_endpoint_resource 'collectionrequests'
end