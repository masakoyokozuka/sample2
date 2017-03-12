class Sys::Publisher < ApplicationRecord
  include Sys::Model::Base

  belongs_to :publishable, polymorphic: true

  before_validation :modify_path
  before_save :check_path
  before_destroy :remove_files

  def site_id
    path.scan(%r{^./sites/(\d+)}).dig(0, 0).try!(:to_i)
  end

  def site
    @site ||= Cms::Site.find_by(id: site_id)
  end

  def modify_path
    self.path = path.gsub(/^#{Rails.root.to_s}/, '.')
  end

  def remove_files(options = {})
    up_path = options[:path] || path
    up_path = ::File.expand_path(path, Rails.root) if up_path.to_s.slice(0, 1) == '/'
    FileUtils.rm(up_path) if FileTest.exist?(up_path)
    FileUtils.rm("#{up_path}.mp3") if FileTest.exist?("#{up_path}.mp3")
    FileUtils.rmdir(::File.dirname(path)) rescue nil
    transcribe self, options  if Zomeki.config.application['sys.log_closed_page']
    return true
  end

protected
  def check_path
    remove_files(:path => path_was) if !path_was.blank? && path_changed?
    return true
  end

  def transcribe(publisher, options={})
    cl = Sys::Closer.new(publisher.attributes)
    cl.published_at   = publisher.created_at.clone rescue nil;
    cl.republished_at = publisher.updated_at.clone rescue nil;
    cl.created_at     = nil
    cl.updated_at     = nil
    cl.path = options[:path] if options[:path]
    cl.save!
  rescue
    false
  end
end
