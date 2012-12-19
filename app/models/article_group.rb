class ArticleGroup < ActiveRecord::Base
  has_many :articles, :class_name => "Article", :foreign_key => "article_group_id"
  
  def self.import(arg)
    @baan_import = BaanImport.where(:id => arg)
    
    csv_file_path = @baan_import.first.baan_upload.path
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})
    
    csv_file.each do |row|
      
      baan_id = row[0].to_s.undress
      description = row[1].to_s.undress
      warn_on = row[3].to_s.undress
    
      article_group = ArticleGroup.find_or_initialize_by_baan_id_and_stocktaking_id(:baan_id => baan_id, :stocktaking_id => "dez-2012")
      if article_group.present? && article_group.new_record?
        article_group.baan_id = baan_id
        article_group.description = description
        article_group.warn_on = warn_on
        article_group.stocktaking_id = "dez-2012"
        article_group.save
      else
        article_group.update_attributes(:baan_id => baan_id,
                                        :description => description,
                                        :warn_on => warn_on)
      end
      
    end
    
  end
  
end
