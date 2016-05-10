class Post < ActiveRecord::Base
  after_save :post_wordpress, on: [:create]

  mount_uploader :file, FileUploader

  private
    def post_wordpress
      wp = Rubypress::Client.new(:host => Rails.application.secrets.rubypress_host, 
                                 :username => Rails.application.secrets.rubypress_username, 
                                 :password => Rails.application.secrets.rubypress_password)

      post_content =  "<div>"\
                      "#{ActionController::Base.helpers.cl_image_tag(self.file.full_public_id, :format => "jpg", :width => 600, :height => 851)}<br />"\
                      "#{ActionController::Base.helpers.cl_image_tag(self.file.full_public_id, :format => "jpg", :width => 600, :height => 851, :page => 2)}<br />"\
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
