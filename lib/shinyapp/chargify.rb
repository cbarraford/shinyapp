require 'json'
require 'rest-client'

module Shinyapp
  module Chargify
    @@endpoint = nil

    def request(path, method = :get, data = {})
      JSON.parse(
        RestClient.send(
          method,
          "https://#{ENV['chargify_user']}:#{ENV['chargify_passwd']}@#{ENV['chargify_url']}#{path}",
          data.to_json,
          content_type: :json,
          accept: :json
        ),
        symbolize_names: true
      )
    end

    def create(attrs)
      request("#{@@endpoint}.json", :post, attrs)
    end

    def list
      request("#{@@endpoint}.json")
    end

    def get(id)
      request("#{@@endpoint}/#{id}.json")
    end

    def update(id, attrs)
      request("#{@@endpoint}/#{id}.json", :put, attrs)
    end

    def delete(id)
      request("#{@@endpoint}/#{id}.json", :delete)
    end

    class Subscription
      include Shinyapp::Chargify
      def initialize
        @@endpoint = 'subscriptions'
      end

      def list_by_customer(id)
        request("/customers/#{id}/#{@@endpoint}.json")
      end
    end

    class Customer
      include Shinyapp::Chargify
      def initialize
        @@endpoint = 'customers'
      end
    end

    class Product
      include Shinyapp::Chargify
      def initialize
        @@endpoint = 'products'
      end
    end

    class Payment
      include Shinyapp::Chargify
      def initialize
        @@endpoint = 'payment_profiles'
      end

      # there is no list function for payment profiles
      def list; end
    end
  end
end
