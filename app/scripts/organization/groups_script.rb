class Organization::GroupsScript < Cms::Script::Publication
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_page(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)

    groups = @node.content.groups.where(state: 'public')
    groups = groups.where(id: params[:target_organization_group_id]) if params[:target_organization_group_id]
    groups.each do |group|
      g_uri = group.public_uri
      g_path = group.public_path
      g_smart_phone_path = group.public_smart_phone_path
      publish_page(@node, uri: "#{g_uri}index.rss", path: "#{g_path}index.rss", dependent: "#{g_uri}rss")
      publish_page(@node, uri: "#{g_uri}index.atom", path: "#{g_path}index.atom", dependent: "#{g_uri}atom")
      publish_page(@node, uri: g_uri, path: g_path, smart_phone_path: g_smart_phone_path, dependent: g_uri)
      publish_more(@node, uri: g_uri, path: g_path, smart_phone_path: g_smart_phone_path, file: 'more', dependent: "#{g_uri}more")
    end
  end
end
