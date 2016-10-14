class Rank::Category < ApplicationRecord
  include Sys::Model::Base

  belongs_to :content, foreign_key: :content_id, class_name: 'Rank::Content::Rank'

end
