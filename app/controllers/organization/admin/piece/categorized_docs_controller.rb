class Organization::Admin::Piece::CategorizedDocsController < Cms::Admin::Piece::BaseController
  def update
    @item = model.find(params[:id])
    @item.attributes = base_params
    @item.updated_at = Time.now
    @item.category_ids = if params[:categories]
                           params[:categories].values.flatten.map{|c| c.to_i if c.present? }.compact.uniq
                         else
                           []
                         end
    _update @item, location: cms_pieces_url
  end
end
