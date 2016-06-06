require 'gmail'

class EmailService

  def initialize(params)
    @post = params[:post]
    #read from gmail
    gmail = Gmail.connect!(Rails.application.secrets.gmail_username,Rails.application.secrets.gmail_password)
    gmail.inbox.find(:unread).each do |email|
      if email.subject.match(/Boletim/i)
        attachment = email.attachments[0]

        #write attachments
        folder = '/tmp/attachments/'
        Dir.mkdir(folder) unless File.exists?(folder)
        File.open(File.join(folder, attachment.filename), "w+b", 0644 ) { |f| f.write attachment.body.decoded }

        #set @post
        @post.title = "Boletim Semanal " + email.subject[-3..-1]
        @post.file = File.open(File.join(folder, attachment.filename))
      end
      email.read!
      email.archive!
    end
  end

end
