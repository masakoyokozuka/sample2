class GpArticle::Public::Piece::CommentsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::Comment.find_by(id: Page.current_piece.id)
    return render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    @comments = @piece.content.public_comments.order(posted_at: :desc)
  end
end
