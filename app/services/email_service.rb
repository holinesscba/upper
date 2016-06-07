class EmailService
  def self.new
    @gmail = Gmail.connect(Rails.application.secrets.gmail_username,Rails.application.secrets.gmail_password)
    @gmail
  end

end
