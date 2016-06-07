require 'singleton'
require 'pry'

class RubypressClient
  include Singleton

  def connect
    @connect = Rubypress::Client.new(:host => Rails.application.secrets.rubypress_host,
                                     :username => Rails.application.secrets.rubypress_username,
                                     :password => Rails.application.secrets.rubypress_password)
  end

end