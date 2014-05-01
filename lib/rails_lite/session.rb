require 'json'
require 'webrick'

class Session
  attr_accessor :value
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    req.cookies.each do |cookie|
     if cookie.name == '_rails_lite_app'
      self.value = JSON.parse(cookie.value) unless cookie.value.nil?
      end
    end
    if self.value.nil?
      self.value = {}
    end
  end

  def [](key)
    self.value[key]
  end

  def []=(key, val)
    self.value[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', self.value.to_json)
  end
end
