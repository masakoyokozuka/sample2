class Sys::UsersRole < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Auth::Site::User

  belongs_to :user, :foreign_key => :user_id, :class_name => 'Sys::User'
  belongs_to :role_name, :foreign_key => :role_id, :class_name => 'Sys::RoleName'
end
