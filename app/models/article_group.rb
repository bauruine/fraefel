class ArticleGroup < ActiveRecord::Base
  has_many :articles, :class_name => "Article", :foreign_key => "article_group_id"
  
  def self.import(arg)
    @baan_import = arg
    #PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      
      baan_id = Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip
      description = Iconv.conv('UTF-8', 'iso-8859-1', row[1]).to_s.chomp.lstrip.rstrip
      warn_on = Iconv.conv('UTF-8', 'iso-8859-1', row[3]).to_s.chomp.lstrip.rstrip
    
      article_group = ArticleGroup.find_or_initialize_by_baan_id(:baan_id => baan_id)
      if article_group.present?
        article_group.update_attributes(:baan_id => baan_id,
                                        :description => description,
                                        :warn_on => warn_on)
      end
    end
  end
  
end
