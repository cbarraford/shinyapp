require 'bcrypt'

module Shinyapp
  class User
    attr_accessor :first, :last, :org, :email, :passwd, :username, :chargify_id
    
    def initialize(user = nil)
      if user.class == String
        user = Shinyapp::Cloudant.request("/#{user}").to_hash
      end
      if user.class == Hash
        user.each do |k,v|
          v = BCrypt::Password.create(v) if k == :passwd
          instance_variable_set("@#{k}",v)
        end
      end
      @_id = @username
    end

    def full_name
      [@first, @last].compact.join(' ')
    end
  
    def create
      # make sure we have all the attrs we need
      vars = self.instance_variables.map do |i|
        self.instance_variable_get(i)
      end
      if vars.include?(nil)
        raise 'cannot create user, not all attributes are set'
      else
        # create account in chargify
        Shinyapp::Chargify::Customer.new.create({
          first_name: @first,
          last_name: @last,
          email: @email,
          organization: @org
          reference: @username
        })
        # create account in cloudant db
        Shinyapp::Cloudant.request('', :post, self.to_json)
      end
    end

    def update(changes)
      # only allow updating of specific user attributes (for security reasons)
      # allowed_fields = %w( first last org email passwd chargify_id )
      # changes.keep_if { |k| allowed_fields.include?(k.to_s) }

      # update attributes
      changes.each do |k,v|
        v = BCrypt::Password.create(v) if k == :passwd
        instance_variable_set("@#{k}",v)
      end

      # save changes
      Shinyapp::Cloudant.request("/#{@username}", :put, self.to_json)
    end

    def delete
      Shinyapp::Cloudant.request("/#{@username}", :delete)
    end

    def valid_passwd?(password)
      BCrypt::Password.new(@passwd) == password
    end

    def subscriptions
      if @chargify_id
        chargify = Shinyapp::Chargify::Subscription.new
        chargify.list_by_customer(@chargify_id)
      else
        []
      end
    end

    def billing
      if @chargify_id
        chargify = Shinyapp::Chargify::Payment.new
        payments = chargify.list
      else
        []
      end
    end

    def to_hash
      user = {}
      self.instance_variables.each do |i|
        key = i.to_s.gsub('@', '').to_sym
        val = self.instance_variable_get(i)
        user[key] = val
      end
      user
    end

    def to_json
      JSON.pretty_generate(self.to_hash)
    end
  end
end
