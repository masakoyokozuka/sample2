class GpArticle::Admin::Docs::HistoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return http_error(404) unless @content = GpArticle::Content::Doc.find_by(id: params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return http_error(404) unless @doc = @content.docs.find_by(id: params[:doc_id])
  end

  def index
    doc_ids = @doc.prev_editions.select(&:state_archived?).map(&:id)
    @items = @content.all_docs.where(id: doc_ids).reorder(display_published_at: :desc, published_at: :desc).paginate(page: params[:page], per_page: 30)
  end

  def show
    @item = @content.all_docs.find(params[:id])
  end
end
