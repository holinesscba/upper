require 'gmail'
require 'singleton'
require 'pry'

class GmailClient
  include Singleton

  def connect
    username = ENV["GMAIL_USERNAME"]
    password = ENV["GMAIL_PASSWORD"]

    @connect = Gmail.connect!(username, password)
  end

  protected

  def config
    Rails.application.secrets
  end
end
