#!/usr/bin/ruby

require 'rubygems'
require 'httpclient'
require 'json'

class Angular
  def initialize(username, password, library)
    @http = HTTPClient.new
    @library = library
    post("/login", :email => username, :password => password)
  end

  def libraries
    get("/data")
  end

  def store(database, document, data)
    post("/data/#{database}/#{document}", data.to_json)
  end

  private

  def post(path, params)
    request(:post, path, params)
  end

  def get(path, params=nil)
    request(:get, path, params)
  end

  def request(method, path, params)
    uri = (path.index("http") == 0) ? path : ("http://#{@library}.getangular.com" + path)
    response = @http.send(method, uri, params)
    if response.code == 302
      get(response.header["Location"][0])
    elsif response.code == 200
      parsed = parse(response)
      status_code = parsed['$status_code']
      raise "#{uri.to_s} responded with #{status_code}" if status_code && status_code != 200
      parsed
    else
      raise "#{uri.to_s} responded with #{response.code}"
    end
  end

  def parse(response)
    begin
      JSON.parse(response.body.content)
    rescue
      {}
    end
  end
end
