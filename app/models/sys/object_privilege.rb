class Sys::ObjectPrivilege < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Auth::Site::Role

  belongs_to :privilegable, polymorphic: true
  belongs_to :concept, class_name: 'Cms::Concept'
  belongs_to :role_name, :foreign_key => 'role_id', :class_name => 'Sys::RoleName'

  validates :role_id, :concept_id, presence: true
  validates :action, presence: true, if: %Q(in_actions.blank?)

  attr_accessor :in_actions

  def in_actions
    @in_actions ||= actions
  end

  def in_actions=(values)
    @_in_actions_changed = true
    @in_actions = if values.kind_of?(Hash)
                    values.map{|k, v| k if v.present? }.compact
                  else
                    []
                  end
  end

  def action_labels(format = nil)
    list = [['閲覧','read'], ['作成','create'], ['編集','update'], ['削除','delete']]
    if format == :hash
      h = {}
      list.each {|c| h[c[1]] = c[0]}
      return h
    end
    list
  end

  def privileges
    self.class.where(role_id: role_id, privilegable: privilegable).order(:action)
  end
  
  def actions
    privileges.collect{|c| c.action}
  end
  
  def action_names
    names = []
    _actions = actions
    action_labels.each do |label, key|
      if actions.index(key)
        names << label
        _actions.delete(key)
      end
    end
    names += _actions
    names
  end
  
  def save
    return super unless @_in_actions_changed
    return false unless valid?
    save_actions
  end
  
  def destroy_actions
    privileges.each {|priv| priv.destroy }
    return true
  end

  protected

  def save_actions
    actions = in_actions.map(&:to_s)

    privileges.each do |priv|
      if actions.index(priv.action)
        actions.delete(priv.action)
      else
        priv.destroy
      end
    end

    actions.each do |action|
      privileges.create(action: action, concept_id: concept_id)
    end
  end
end
