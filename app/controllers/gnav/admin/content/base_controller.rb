class Gnav::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Gnav::Content::MenuItem
  end
end
