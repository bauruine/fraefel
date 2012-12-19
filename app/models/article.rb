class Article < ActiveRecord::Base
  belongs_to :depot, :class_name => "Depot", :foreign_key => "depot_id"
  belongs_to :article_group, :class_name => "ArticleGroup", :foreign_key => "article_group_id"
  attr_accessor :scii_sia
  
  validates_presence_of :in_stock, :if => Proc.new { |article| article.scii_sia }
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    
    csv_file_path = @baan_import.baan_upload.path
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})
    
    csv_file.each do |row|
      baan_acces_id = row[0].to_s.undress
      article_code = row[1].to_s.undress
      depot_code = row[2].to_s.undress
      depot = Depot.where(:code => depot_code).first
      article_type = row[3].to_s.undress
      signal_code_description = row[4].to_s.undress
      description = row[5].to_s.undress
      search_key_01 = row[6].to_s.undress
      search_key_02 = row[7].to_s.undress
      material = row[8].to_s.undress
      factor = row[9].to_s.undress
      zone_code = row[10].to_s.undress
      stock_unit = row[11].to_s.undress
      order_unit = row[12].to_s.undress
      trade_partner_name = row[13].to_s.undress
      trade_partner_additional_info = row[14].to_s.undress
      
      articles = Article.where(:baan_acces_id => baan_acces_id)
      if articles.present?
        articles.each do |article|
          article.update_attributes(:article_code => article_code,
                                    :depot => depot,
                                    :signal_code_description => signal_code_description,
                                    :description => description,
                                    :search_key_01 => search_key_01,
                                    :search_key_02 => search_key_02,
                                    :material => material,
                                    :factor => factor,
                                    :zone_code => zone_code,
                                    :stock_unit => stock_unit,
                                    :order_unit => order_unit,
                                    :trade_partner_name => trade_partner_name,
                                    :trade_partner_additional_info => trade_partner_additional_info)
        end
      end
    end
  end
  
  def self.import_extras(arg)
    @baan_import = BaanImport.find(arg)
    
    csv_file_path = @baan_import.baan_upload.path
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})
    
    csv_file.each do |row|
      
      baan_acces_id = row[0].to_s.undress
      rack_group_number = row[1].to_s.undress
      rack_root_number = row[2].to_s.undress
      rack_part_number = row[3].to_s.undress
      rack_root_part_number = rack_root_number + "." + rack_part_number
      rack_tray_number = row[4].to_s.undress
      rack_box_number = row[5].to_s.undress
    
      articles = Article.where(:baan_acces_id => baan_acces_id)
      if articles.present?
        articles.each do |article|
          article.update_attributes(:rack_group_number => rack_group_number,
                                    :rack_root_number => rack_root_number,
                                    :rack_part_number => rack_part_number,
                                    :rack_root_part_number => rack_root_part_number,
                                    :rack_tray_number => rack_tray_number,
                                    :rack_box_number => rack_box_number)
        end
      end
    end
  end
  
  def self.import_extras_1(arg)
    @baan_import = BaanImport.find(arg)
    
    csv_file_path = @baan_import.baan_upload.path
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})
    
    csv_file.each do |row|
      
      article_code = row[0].to_s.undress
      baan_article_group_id = row[3].to_s.undress
      price = row[1].to_s.undress
      article_group = ArticleGroup.find_by_baan_id(baan_article_group_id)
      
      articles = Article.where(:article_code => article_code)
      if articles.present?
        articles.each do |article|
          article.update_attributes(:article_group => article_group, :price => price)
        end
      end
    end
  end
  
  def self.import_baan_file(arg)
    @baan_import = BaanImport.where(:id => arg)
    
    csv_file_path = @baan_import.first.baan_upload.path
    csv_file = CSV.open(csv_file_path, "rb:us-ascii:UTF-8", {:col_sep => ";"})
    
    csv_file.each do |row|
      
      baan_orno = row[0].to_s.undress
      baan_cntn = row[1].to_s.undress
      baan_pono = row[2].to_s.undress
      baan_loca = row[4].to_s
      baan_item = row[5].to_s
      baan_clot = row[6].to_s
      baan_stun = row[8].to_s.undress
      baan_qstk = row[9].to_s.undress
      baan_qstr = row[10].to_s.undress
      baan_csts = row[15].to_s.undress
      baan_recd = row[17].to_s.undress
      baan_reco = row[18].to_s.undress
      baan_appr = row[19].to_s.undress
      baan_cadj = row[20].to_s.undress
      
      article_code = row[5].to_s.undress
      depot_number = row[3].to_s.undress
      old_stock = row[11].to_s.undress
      baan_acces_id = "#{article_code}x#{depot_number}"
      
      _article = Article.where(:baan_acces_id => baan_acces_id, :stocktaking_id => "dez-2012")
      
      if _article.present?
        _article.first.update_attributes(:old_stock => old_stock,
                       :baan_orno => baan_orno,
                       :baan_cntn => baan_cntn,
                       :baan_pono => baan_pono,
                       :baan_loca => baan_loca,
                       :baan_item => baan_item,
                       :baan_clot => baan_clot,
                       :baan_stun => baan_stun,
                       :baan_qstk => baan_qstk,
                       :baan_qstr => baan_qstr,
                       :baan_csts => baan_csts,
                       :baan_recd => baan_recd,
                       :baan_reco => baan_reco,
                       :baan_appr => baan_appr,
                       :baan_cadj => baan_cadj,
                       :considered => true,
                       :baan_acces_id => baan_acces_id,
                       :stocktaking_id => "dez-2012")
      else
        Article.create(:old_stock => old_stock,
                       :baan_orno => baan_orno,
                       :baan_cntn => baan_cntn,
                       :baan_pono => baan_pono,
                       :baan_loca => baan_loca,
                       :baan_item => baan_item,
                       :baan_clot => baan_clot,
                       :baan_stun => baan_stun,
                       :baan_qstk => baan_qstk,
                       :baan_qstr => baan_qstr,
                       :baan_csts => baan_csts,
                       :baan_recd => baan_recd,
                       :baan_reco => baan_reco,
                       :baan_appr => baan_appr,
                       :baan_cadj => baan_cadj,
                       :considered => true,
                       :baan_acces_id => baan_acces_id,
                       :stocktaking_id => "dez-2012")
      end
      
    end
  end
  
  def self.calculate_difference(arg)
    @articles = Article.where(:rack_group_number => arg, :considered => true).where("old_stock IS NOT NULL").where("in_stock IS NOT NULL").where("in_stock != ''")
    @articles.each do |article|
      article_warn_on = article.article_group.present? ? article.article_group.warn_on : 10
      article_warn_on_price = article.article_group.present? && article.article_group.warn_on_price.present? ? article.article_group.warn_on_price.to_f : 3000
      
      if article.in_stock.split(".").size > 1
        b = BigDecimal(article.in_stock)
      else
        b = Integer(article.in_stock)
      end
      if article.old_stock.split(".").size > 1
        a = BigDecimal(article.old_stock)
      else
        a = Integer(article.old_stock)
      end
      
      baan_vstk = (a - b) * -1
      a_b_difference = a - b < 0 ? ((a - b) * -1) : (a - b)
      price_difference = (article.price.present? ? article.price : article.price.to_f) * b
      if (a_b_difference > 0 && a_b_difference >= ((a / 100) * article_warn_on)) or (price_difference > article_warn_on_price)
        article.update_attributes(:should_be_checked => true, :baan_vstk => baan_vstk, :baan_vstr => baan_vstk)
      else
        article.update_attributes(:should_be_checked => false, :baan_vstk => baan_vstk, :baan_vstr => baan_vstk)
      end
    end
  end
  
end
