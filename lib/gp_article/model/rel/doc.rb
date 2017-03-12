module GpArticle::Model::Rel::Doc
  attr_accessor :in_rel_doc_ids

  def rel_docs(options={})
    docs = []
    ids = rel_doc_ids.to_s.split(' ').uniq
    return docs if ids.size == 0
    ids.each do |id|
      doc = GpArticle::Doc.find_by(id: id)
      if options[:edit]
        doc ||= GpArticle::Doc.where(:name => id ).first
      else
        doc ||= GpArticle::Doc.where(:name => id , :state=>'public').first
      end

      docs << doc if doc
    end
    docs
  end

  def in_rel_doc_ids
    unless val = read_attribute(:in_rel_doc_ids)
      write_attribute(:in_rel_doc_ids, rel_doc_ids.to_s.split(' ').uniq)
    end
    read_attribute(:in_rel_doc_ids)
  end

  def in_rel_doc_ids=(ids)
    _ids = []
    if ids.is_a?(Array)
      ids.each {|val| _ids << GpArticle::Doc.find_by(id: val).try(:name) || val}
      write_attribute(:rel_doc_ids, _ids.join(' '))
    elsif ids.is_a?(Hash)
      ids.each {|key, val| _ids << GpArticle::Doc.find_by(id: val).try(:name) || val}
      write_attribute(:rel_doc_ids, _ids.join(' '))
    elsif ids.is_a?(String)
      _ids = ids.split(' ').map{|id| GpArticle::Doc.find_by(id: id).try(:name) || id }.uniq
      write_attribute(:rel_doc_ids, _ids.join(' '))
    else
      write_attribute(:rel_doc_ids, ids)
    end
  end
end
