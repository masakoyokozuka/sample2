class Cms::DataFileNode < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept::Creator

  include Cms::Base::PublishQueue::Bracketee

  has_many :files, :foreign_key => :node_id, :class_name => 'Cms::DataFile', :primary_key => :id

  validates :name, presence: true, uniqueness: { scope: :concept_id }
  validate :validate_name

  after_destroy :remove_files

  def label(separator = " : ")
    label = name
    unless title.blank?
      label += "#{separator}#{title}"
    end
    label
  end

  def validate_name
    return if Zomeki.config.application['upload.allow_japanese_filename']
    if !name.blank?
      if name !~ /^[0-9a-zA-Z_\-]+$/
        errors.add :name, "は半角英数字を入力してください。"
      end
    end
  end

private
  def remove_files
    files.each {|file| file.destroy }
    return true
  end

  def changed_bracket_names
    names = [name, name_was].select(&:present?).uniq
    names.map { |name| files.map { |file| "file/#{name}/#{file.name}" } }.flatten
  end
end
