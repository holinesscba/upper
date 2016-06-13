class PostService
  class Builder
    def self.build
      new.build
    end

    attr_accessor :email_client, :post, :attachment

    def initialize(email_client = GmailClient.instance)
      @email_client = email_client.connect
      @post = Post.new
      @attachment = nil
    end

    def build
      if unread_messages?
        self.errors.add(:base, "No unread mail.")
        return false
      else
        email = gmail.inbox.find(:unread, :labels => 'boletim').first

        email.attachments.each do |file|
          if file_extension(file) == "pdf"
            attachment = file
          end
        end

        if attachment.nil?
          self.errors.add(:base, "No pdf file.")
          return false
        end

        write_attachment(attachment)

        email_done!(email)

        post.tap do |p|
          p.title = "Boletim Semanal " + email.subject[-3..-1]
          p.file = File.open(File.join(folder, attachment.filename))
        end
      end
    end

    private

    def file_extension(file)
      file.filename[-3..-1]
    end

    def write_attachment(attachment)
      Attachment.save(attachment)
    end

    def email_done!(email)
      email.read!
      email.archive! # doesn't work by gmail gem issue.
    end

    def unread_messages?
      email_client.inbox.count(:unread) == 0
    end
  end
end
