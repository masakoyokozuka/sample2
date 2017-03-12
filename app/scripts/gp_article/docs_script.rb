class GpArticle::DocsScript < Cms::Script::Publication
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_page(@node, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
    publish_page(@node, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)
    publish_more_params = {
      uri: uri, path: path, smart_phone_path: smart_phone_path,
      limit: @node.content.try(:doc_publish_more_pages),
      start_at: @node.content.try(:published_first_day),
      end_at: @node.content.try(:published_last_day),
      period: @node.content.try(:doc_list_pagination),
      target_date: params[:target_date]
    }
    if @node.content.try(:doc_list_pagination) != 'simple' && params[:target_date].present?
      publish_more_by_period(@node, publish_more_params)
    else
      publish_more(@node, publish_more_params)
    end
  end

  def publish_doc
    docs = @node.content.public_docs.where(id: params[:target_doc_id])
    docs.find_each do |doc|
      ::Script.progress(doc) do
        uri = doc.public_uri
        path = doc.public_path
        if doc.publish(render_public_as_string(uri, site: doc.content.site))
          uri_ruby = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
          path_ruby = "#{path}.r"
          doc.publish_page(render_public_as_string(uri_ruby, site: doc.content.site), path: path_ruby, dependent: :ruby)
          doc.publish_page(render_public_as_string(uri, site: doc.content.site, agent_type: :smart_phone),
                      path: doc.public_smart_phone_path, dependent: :smart_phone)
        end
      end
    end
  end

  def publish_by_task
    if (item = params[:item]) && (item.state_approved? || item.state_prepared?)
      ::Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      uri = item.public_uri.to_s
      path = item.public_path.to_s

      # Renew edition before render_public_as_string
      item.update_attribute(:state, 'public')

      if item.publish(render_public_as_string(uri, site: item.content.site))
        Sys::OperationLog.script_log(:item => item, :site => item.content.site, :action => 'publish')
      else
        raise item.errors.full_messages
      end

      if item.published? || !::File.exist?("#{path}.r")
        uri_ruby = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
        path_ruby = "#{path}.r"
        item.publish_page(render_public_as_string(uri_ruby, site: item.content.site),
                          path: path_ruby, dependent: :ruby)
      end

      info_log %Q!OK: Published to "#{path}"!
      params[:task].destroy
      ::Script.success
    end
  end

  def close_by_task
    if (item = params[:item]) && item.state_public?
      ::Script.current
      info_log "-- Close: #{item.class}##{item.id}"

      item.close

      Sys::OperationLog.script_log(:item => item, :site => item.content.site, :action => 'close')

      info_log 'OK: Finished'
      params[:task].destroy
      ::Script.success
    end
  end
end
