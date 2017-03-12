class GpCategory::Public::Piece::FeedsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::Feed.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece
    
    @item = Page.current_item
  end
  
  def index
    case @item
    when Cms::Node
      @feed = true if @item.model == 'GpCategory::Doc'
    when GpCategory::Category
      @feed = true 
    end
  end
end
