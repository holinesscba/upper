class Post < ActiveRecord::Base
  before_save :read_gmail, on: [:create]
  after_save :post_wordpress, on: [:create]

  mount_uploader :file, FileUploader

  private
    def read_gmail
      # connect and instance
      gmail = GmailClient.instance.connect

      if gmail.inbox.count(:unread) == 0
        self.errors.add(:base, "No unread mail.") 
        return false
      else
        email = gmail.inbox.find(:unread, :labels => 'boletim').first
        attachment = email.attachments[0]

        #write attachments
        folder = '/tmp/attachments/'
        Dir.mkdir(folder) unless File.exists?(folder)
        File.open(File.join(folder, attachment.filename), "w+b", 0644 ) { |f| f.write attachment.body.decoded }

        #set @post
        self.title = "Boletim Semanal " + email.subject[-3..-1]
        self.file = File.open(File.join(folder, attachment.filename))

        email.read!
        email.archive! # doesn't work by gmail gem issue.
      end
    end

    def post_wordpress
      wp = RubypressClient.instance.connect

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
