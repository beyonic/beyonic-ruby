# frozen_string_literal: true

module Beyonic::AbstractApi
  class ApiError < StandardError
  end

  module ClassMethods
    def set_endpoint_resource(resource)
      @endpoint_url = Beyonic.endpoint_base + resource
    end

    def create(payload = {}, header_overrides = {})
      # transform metadata from hash notation to dot notation
      if (payload.key? :metadata) && !payload[:metadata].empty?
        payload[:metadata].each do |key, value|
          payload["metadata.#{key}"] = value
        end
        payload.delete :metadata
      end
      resp = RestClient.post(@endpoint_url, payload, headers(header_overrides))
      new(Oj.load(resp))
    rescue RestClient::BadRequest => e
      raise ApiError.new(Oj.load(e.response.body))
    end

    def list(payload = {})
      # Turn payload into query parameters
      require 'addressable/uri'
      uri = Addressable::URI.new
      uri.query_values = payload

      resp = RestClient.get(@endpoint_url + '?' + uri.query, headers)
      ret = new(Oj.load(resp))
      ret.results = ret.results.map { |obj_attrs| new(obj_attrs) }
      ret
    end

    def get(id)
      resp = RestClient.get("#{@endpoint_url}/#{id}", headers)
      new(Oj.load(resp))
    end

    def update(id, payload, header_overrides = {})
      resp = RestClient.patch("#{@endpoint_url}/#{id}", payload, headers(header_overrides))
      new(Oj.load(resp))
    rescue RestClient::BadRequest => e
      raise ApiError.new(Oj.load(e.response.body))
    end

    def delete(id)
      resp = RestClient.delete("#{@endpoint_url}/#{id}", headers)
      return true if resp == ''
    end

    private

    def headers(header_overrides = {})
      headers_hash = {}
      headers_hash.merge!({ 'Authorization' => "Token #{Beyonic.api_key}" }) if Beyonic.api_key
      headers_hash.merge!({ 'Beyonic-Version' => Beyonic.api_version }) if Beyonic.api_version
      headers_hash.merge!({ 'Beyonic-Client' => 'Ruby' })
      headers_hash.merge!({ 'Beyonic-Client-Version' => Beyonic::VERSION })
      headers_hash.merge!(header_overrides)
      headers_hash
    end
  end

  module InstanceMethods
    def save
      if respond_to?(:id) && !id.nil?
        self.class.update(id, to_h)
      else
        self.class.create(to_h)
      end
    end

    def []=(name, value)
      if name.to_sym == :id
        self.id = value
      else
        super(name, value)
      end
    end
  end

  module Initializer
    def initialize(*args)
      super(*args)
      # We should define it after Object initialization
      define_singleton_method(:id=) do |_val|
        raise "Can't change id of existing #{self.class}"
      end
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
    receiver.send :prepend, Initializer
  end
end
