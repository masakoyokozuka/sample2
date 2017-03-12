class AdBanner::Admin::ClicksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = AdBanner::Content::Banner.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    @banner = @content.banners.find(params[:banner_id])
  end

  def index
    @items = @banner.clicks.paginate(page: params[:page], per_page: 50)
    _index @items
  end
end
