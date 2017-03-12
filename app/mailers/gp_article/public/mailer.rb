class GpArticle::Public::Mailer < ApplicationMailer
  def commented_notification(comment)
    @doc = comment.doc
    @core_uri = @doc.content.site.main_admin_uri

    from = comment.author_name
    from << " <#{comment.author_email}>" if comment.author_email.present?

    return if from.blank? || @doc.creator.user.email.blank?

    mail from: from,
         to: @doc.creator.user.email,
         subject: "#{@doc.content.name}（#{@doc.content.site.name}）：コメント通知メール"
  end
end
