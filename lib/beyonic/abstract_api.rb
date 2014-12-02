module Beyonic::AbstractApi
  class ApiError < StandardError
  end

  module ClassMethods

    require "rest_client"
    require "oj"

    def set_endpoint(url)
      @endpoint_url = url
    end

    def set_api_version(version)
      @api_version = version
    end

    def create(payload = {})
      resp = RestClient.post(@endpoint_url, payload, headers)
      self.new(Oj.load(resp))
    rescue RestClient::BadRequest => e
      raise ApiError.new(Oj.load(e.response.body))
    end

    def list
      resp = RestClient.get(@endpoint_url, headers)
      Oj.load(resp).map { |obj_attrs| self.new(obj_attrs)}
    end

    def get(id)
      resp = RestClient.get("#{@endpoint_url}/#{id}", headers)
      self.new(Oj.load(resp))
    end

    def update(id, payload)
      resp = RestClient.patch("#{@endpoint_url}/#{id}", payload, headers)
      self.new(Oj.load(resp))
      rescue RestClient::BadRequest => e
        raise ApiError.new(Oj.load(e.response.body))
    end

    def delete(id)
      resp = RestClient.delete("#{@endpoint_url}/#{id}", headers)
      return true if resp == ""
    end

    private

    def headers
      headers_hash = {}
      headers_hash.merge!({"Authorization" => "Token #{Beyonic.api_key}"}) if Beyonic.api_key
      headers_hash.merge!({"Beyonic-Version" => @api_version}) if @api_version
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
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

end