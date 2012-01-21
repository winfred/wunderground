require 'httparty'
require 'json'
require 'cgi'
require 'addressable/uri'

class Wunderground
  include HTTParty
  format :json
  default_timeout 30
  
  class MissingAPIKey < RuntimeError; end
  class APIError < RuntimeError; end

  attr_accessor :api_key, :timeout, :throws_exceptions, :language

  def initialize(api_key = nil, extra_params = {})
    @api_key = api_key || ENV['WUNDERGROUND_API_KEY'] || ENV['WUNDERGROUND_APIKEY'] || self.class.api_key
    @timeout = extra_params[:timeout] || 30
    @throws_exceptions = extra_params[:throws_exceptions] || false
    @language = extra_params[:language]
  end

  def base_api_url
    "http://api.wunderground.com/api/#{api_key}/"
  end
  def get_history_for(date,*args)
    history = (date.class == String ? "history_#{date}" : "history_#{date.strftime("%Y%m%d")}")
    send("get_#{history}_for",args)
  end

protected

  def call(method, params = {})
    raise MissingAPIKey if @api_key.nil?
    response = self.class.get(base_api_url << method, :timeout => @timeout)
    begin
      response = JSON.parse(response.body)
    rescue
      response = response.body
    end

    if @throws_exceptions && response.is_a?(Hash) && response["response"]["error"]
      raise APIError, "#{response["response"]["error"]["type"]}: #{response["response"]["error"]["description"]})"
    end

    response
  end

  def method_missing(method, *args)
    raise NoMethodError, "undefined method: #{method} for Wunderground" unless method.to_s.start_with?("get_") and method.to_s.end_with?("_for") 
    url = method.to_s.gsub("get_","").gsub("_for","").gsub("_and_","/")
    url << "/lang:#{@language}" if @language 
    if Hash.try_convert(args[0]) 
      url = url.sub(/\/lang:.*/,'') and url << "/lang:#{args[0][:lang]}" if args[0][:lang] 
      ip_address = args[0][:geo_ip] and args.push("autoip") if args[0][:geo_ip]
      args.delete_at(0) 
    end
    call(url <<'/q/'<< args.join('/') << ".json" << (ip_address.nil? ? '': "?geo_ip=#{ip_address}"))
  end

  class << self
    attr_accessor :api_key, :timeout
    def method_missing(sym, *args, &block)
      new(self.api_key, self.attributes).send(sym, *args, &block)
    end
  end
end

