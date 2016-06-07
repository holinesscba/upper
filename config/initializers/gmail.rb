require 'gmail'
require 'singleton'
require 'pry'

class GmailClient
  include Singleton

  def connect
    @connect = Gmail.connect!(Rails.application.secrets.gmail_username,Rails.application.secrets.gmail_password)
  end

end
