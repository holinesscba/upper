class Post < ActiveRecord::Base
  before_save :read_gmail, on: [:create]
  after_save :post_wordpress, on: [:create]

  mount_uploader :file, FileUploader

  private
    def read_gmail
      #connect
      GmailClient.instance.connect

      #read from gmail
      gmail = GmailClient.instance

      if gmail.inbox.count(:unread) == 0
        fail "Unread email not found."
      else
        gmail.inbox.find(:unread).each do |email|
          if email.subject.match(/Boletim/i)
            attachment = email.attachments[0]

            #write attachments
            folder = '/tmp/attachments/'
            Dir.mkdir(folder) unless File.exists?(folder)
            File.open(File.join(folder, attachment.filename), "w+b", 0644 ) { |f| f.write attachment.body.decoded }

            #set @post
            self.title = "Boletim Semanal " + email.subject[-3..-1]
            self.file = File.open(File.join(folder, attachment.filename))
          end
          email.read!
          email.archive!
        end
      end
    end

    def post_wordpress
      wp = Rubypress::Client.new(:host => Rails.application.secrets.rubypress_host,
                                 :username => Rails.application.secrets.rubypress_username,
                                 :password => Rails.application.secrets.rubypress_password)

      post_content =  "<div>"\
                      "#{ActionController::Base.helpers.cl_image_tag(self.file.full_public_id, :format => "jpg", :width => 600, :crop => :fit)}<br />"\
                      "#{ActionController::Base.helpers.cl_image_tag(self.file.full_public_id, :format => "jpg", :width => 600, :crop => :fit, :page => 2)}<br />"\
                      "<div>#{self.title}</div>"\
                      "</div>"

      wp.newPost( :blog_id => 0, # 0 unless using WP Multi-Site, then use the blog id
                  :content => {
                               :post_status  => "draft",
                               :post_date    => Time.now,
                               :post_content => post_content,
                               :post_title   => self.title,
                               :post_name    => "/#{self.title.parameterize}",
                               :post_author  => 5, # 1 if there is only the admin user, otherwise the user's id
                               :terms_names  => {
                                  :category   => ['Boletim Semanal'],
                                  :post_tag => [Time.now.year]
                                                }
                               }
                  )

    end

end
