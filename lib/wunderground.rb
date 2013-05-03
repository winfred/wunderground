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

  def initialize(*args)
    extra_params = {}
    if !args.nil?
      api_key = args.first if args.first.is_a?(String)
      extra_params = args.last if args.last.is_a?(Hash)
    end
    
    @api_key = api_key || ENV['WUNDERGROUND_API_KEY'] || ENV['WUNDERGROUND_APIKEY'] || self.class.api_key
    @timeout = extra_params[:timeout] || 30
    @throws_exceptions = extra_params[:throws_exceptions] || false
    @language = extra_params[:language]
  end

  def base_api_url
    "http://api.wunderground.com/api/#{api_key}/"
  end

  def history_for(date,*args)
    history = (date.class == String ? "history_#{date}" : "history_#{date.strftime("%Y%m%d")}")
    send("#{history}_for",*args)
  end

  def planner_for(date,*args)
    send("planner_#{date}_for",args) and return if date.class == String
    range = date.strftime("%m%d") << args[0].strftime("%m%d")    
    args.delete_at(0)
    send("planner_#{range}_for",*args)
  end

  def respond_to?(method)
    method_missing_match?(method) || super(method)
  end

  protected

  def call(method, timeout)
    raise MissingAPIKey if @api_key.nil?
    response = self.class.get(base_api_url << method, :timeout => (timeout || @timeout))
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
    super(method, *args) unless method_missing_match?(method)
    url = method.to_s.gsub("_for","").gsub("_and_","/")
    url << "/lang:#{@language}" if @language
    if args.last.instance_of? Hash
      opts = args.pop 
      url = url.sub(/\/lang:.*/,'') and url << "/lang:#{opts[:lang]}" if opts[:lang] 
      ip_address = opts[:geo_ip] and args.push("autoip") if opts[:geo_ip]
      timeout = opts[:timeout]
    end
    call(url <<'/q/'<< args.join('/') << ".json" << (ip_address ? "?geo_ip=#{ip_address}" : ''),timeout)
  end

  class << self
    attr_accessor :api_key, :timeout
    def method_missing(sym, *args, &block)
      new(self.api_key, self.attributes).send(sym, *args, &block)
    end
  end

  private

  def method_missing_match?(method)
    method.to_s.end_with?("_for")
  end
end