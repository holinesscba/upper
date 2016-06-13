class Attachment
  DEFAULT_DIR = '/tmp/attachments'

  attr_reader :attachment

  def self.save(attachment)
    create_directory

    new(attachment).save
  end

  def initialize(attachment)
    @attachment = attachment
  end

  def save
    File.open(filepath, "w+b", 0644) do |f|
      f.write(attachment.body.decoded)
    end
  end

  private

  def self.create_directory
    Dir.mkdir(DEFAULT_DIR) unless File.exists?(DEFAULT_DIR)
  end

  def filepath
    File.join(DEFAULT_DIR, attachment.filename)
  end
end
