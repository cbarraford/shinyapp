require 'json'
require 'rest-client'

module Shinyapp
  module Cloudant
    @@user = ENV['cloudant_user']
    @@passwd = ENV['cloudant_passwd']
    @@url = ENV['cloudant_url'] 

    def self.request(path, method = :get, data = "{}")
      url = "https://#{@@user}:#{@@passwd}@#{@@url}#{path}"
      if method == :get
        JSON.parse(
          RestClient.send(
            method,
            url,
            content_type: :json,
            accept: :json
          )
        )
      else
        JSON.parse(
          RestClient.send(
            method,
            url,
            data,
            content_type: :json,
            accept: :json
          )
        )
      end
    end
  end
end
