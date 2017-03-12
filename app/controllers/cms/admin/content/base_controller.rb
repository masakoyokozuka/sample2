class Cms::Admin::Content::BaseController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  before_action :pre_dispatch_content
  
  def pre_dispatch_content
    @content = Cms::Content.find(params[:id])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def model
    @model_class ||= self.class.to_s.gsub(/^(\w+)::Admin/, '\1').gsub(/Controller$/, '').singularize.constantize
  rescue
    @model_class = Cms::Content
  end

  def index
    exit
  end

  def show
    @item = model.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    exit
  end

  def create
    exit
  end

  def update
    @item = model.find(params[:id])
    @item.attributes = base_params

    _update @item do
      respond_to do |format|
        format.html { return redirect_to(cms_contents_path) }
      end
    end
  end

  def destroy
    @item = model.find(params[:id])
    _destroy @item do
      respond_to do |format|
        format.html { return redirect_to(cms_contents_path) }
      end
    end
  end

  private

  def base_params
    params.require(:item).permit(
      :code, :concept_id, :name, :note, :sort_no,
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
