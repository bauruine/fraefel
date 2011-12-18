class Article < ActiveRecord::Base
  belongs_to :depot, :class_name => "Depot", :foreign_key => "depot_id"
  belongs_to :article_group, :class_name => "ArticleGroup", :foreign_key => "article_group_id"
  
  def self.import(arg)
    @baan_import = arg
    #PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      
      baan_acces_id = Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip
      article_code = Iconv.conv('UTF-8', 'iso-8859-1', row[1]).to_s.chomp.lstrip.rstrip
      depot_code = Iconv.conv('UTF-8', 'iso-8859-1', row[2]).to_s.chomp.lstrip.rstrip
      depot = Depot.where(:code => depot_code).first
      article_type = Iconv.conv('UTF-8', 'iso-8859-1', row[3]).to_s.chomp.lstrip.rstrip
      signal_code_description = Iconv.conv('UTF-8', 'iso-8859-1', row[4]).to_s.chomp.lstrip.rstrip
      description = Iconv.conv('UTF-8', 'iso-8859-1', row[5]).to_s.chomp.lstrip.rstrip
      search_key_01 = Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip
      search_key_02 = Iconv.conv('UTF-8', 'iso-8859-1', row[7]).to_s.chomp.lstrip.rstrip
      material = Iconv.conv('UTF-8', 'iso-8859-1', row[8]).to_s.chomp.lstrip.rstrip
      factor = Iconv.conv('UTF-8', 'iso-8859-1', row[9]).to_s.chomp.lstrip.rstrip
      zone_code = Iconv.conv('UTF-8', 'iso-8859-1', row[10]).to_s.chomp.lstrip.rstrip
      stock_unit = Iconv.conv('UTF-8', 'iso-8859-1', row[11]).to_s.chomp.lstrip.rstrip
      order_unit = Iconv.conv('UTF-8', 'iso-8859-1', row[12]).to_s.chomp.lstrip.rstrip
      trade_partner_name = Iconv.conv('UTF-8', 'iso-8859-1', row[13]).to_s.chomp.lstrip.rstrip
      trade_partner_additional_info = Iconv.conv('UTF-8', 'iso-8859-1', row[14]).to_s.chomp.lstrip.rstrip
    
      article = Article.find_or_initialize_by_baan_acces_id(:baan_acces_id => baan_acces_id)
      if article.present? && article.new_record?
        article.baan_acces_id = baan_acces_id
        article.article_code = article_code
        article.depot = depot
        article.signal_code_description = signal_code_description
        article.description = description
        article.search_key_01 = search_key_01
        article.search_key_02 = search_key_02
        article.material = material
        article.factor = factor
        article.zone_code = zone_code
        article.stock_unit = stock_unit
        article.order_unit = order_unit
        article.trade_partner_name = trade_partner_name
        article.trade_partner_additional_info = trade_partner_additional_info
        article.save
      else
        article.update_attributes(:baan_acces_id => baan_acces_id,
                                  :article_code => article_code,
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
  
  def self.import_extras(arg)
    @baan_import = arg
    #PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      
      baan_acces_id = Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip
      rack_group_number = Iconv.conv('UTF-8', 'iso-8859-1', row[1]).to_s.chomp.lstrip.rstrip
      rack_root_number = Iconv.conv('UTF-8', 'iso-8859-1', row[2]).to_s.chomp.lstrip.rstrip
      rack_part_number = Iconv.conv('UTF-8', 'iso-8859-1', row[3]).to_s.chomp.lstrip.rstrip
      rack_root_part_number = rack_root_number + "." + rack_part_number
      rack_tray_number = Iconv.conv('UTF-8', 'iso-8859-1', row[4]).to_s.chomp.lstrip.rstrip
      rack_box_number = Iconv.conv('UTF-8', 'iso-8859-1', row[5]).to_s.chomp.lstrip.rstrip
    
      article = Article.find_or_initialize_by_baan_acces_id(:baan_acces_id => baan_acces_id)
      if article.present?
        article.update_attributes(:rack_group_number => rack_group_number,
                                  :rack_root_number => rack_root_number,
                                  :rack_part_number => rack_part_number,
                                  :rack_root_part_number => rack_root_part_number,
                                  :rack_tray_number => rack_tray_number,
                                  :rack_box_number => rack_box_number)
      end
    end
  end
  
  def self.import_extras_1(arg)
    @baan_import = arg
    #PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      
      article_code = Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip
      baan_article_group_id = Iconv.conv('UTF-8', 'iso-8859-1', row[3]).to_s.chomp.lstrip.rstrip
      price = Iconv.conv('UTF-8', 'iso-8859-1', row[1]).to_s.chomp.lstrip.rstrip
      article_group = ArticleGroup.find_by_baan_id(baan_article_group_id)
    
      Article.where(:article_code => article_code).each do |article|
        article.update_attributes(:article_group => article_group, :price => price)
      end
    end
  end
  
  def self.import_baan_file(arg)
    @baan_import = arg
    #PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";"}) do |row|
      
      baan_orno = Iconv.conv('UTF-8', 'us-ascii', row[0]).to_s.chomp.lstrip.rstrip
      baan_cntn = Iconv.conv('UTF-8', 'us-ascii', row[1]).to_s.chomp.lstrip.rstrip
      baan_pono = Iconv.conv('UTF-8', 'us-ascii', row[2]).to_s.chomp.lstrip.rstrip
      baan_loca = Iconv.conv('UTF-8', 'us-ascii', row[4]).to_s
      baan_item = Iconv.conv('UTF-8', 'us-ascii', row[5]).to_s
      baan_clot = Iconv.conv('UTF-8', 'us-ascii', row[6]).to_s
      baan_stun = Iconv.conv('UTF-8', 'us-ascii', row[8]).to_s.chomp.lstrip.rstrip
      baan_qstk = Iconv.conv('UTF-8', 'us-ascii', row[9]).to_s.chomp.lstrip.rstrip
      baan_qstr = Iconv.conv('UTF-8', 'us-ascii', row[10]).to_s.chomp.lstrip.rstrip
      baan_csts = Iconv.conv('UTF-8', 'us-ascii', row[15]).to_s.chomp.lstrip.rstrip
      baan_recd = Iconv.conv('UTF-8', 'us-ascii', row[17]).to_s.chomp.lstrip.rstrip
      baan_reco = Iconv.conv('UTF-8', 'us-ascii', row[18]).to_s.chomp.lstrip.rstrip
      baan_appr = Iconv.conv('UTF-8', 'us-ascii', row[19]).to_s.chomp.lstrip.rstrip
      baan_cadj = Iconv.conv('UTF-8', 'us-ascii', row[20]).to_s.chomp.lstrip.rstrip
      
      article_code = Iconv.conv('UTF-8', 'us-ascii', row[5]).to_s.chomp.lstrip.rstrip
      depot_number = Iconv.conv('UTF-8', 'us-ascii', row[3]).to_s.chomp.lstrip.rstrip
      old_stock = Iconv.conv('UTF-8', 'us-ascii', row[11]).to_s.chomp.lstrip.rstrip
      baan_acces_id = "#{article_code}x#{depot_number}"
      articles = Article.where(:baan_acces_id => baan_acces_id)
      
      if articles.present?
        articles.each do |article|
          article.update_attributes(:old_stock => old_stock,
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
                                    :considered => true)
        end
      end
      
    end
  end
  
  def self.calculate_difference(arg)
    @articles = Article.where(:rack_group_number => arg).where("old_stock IS NOT NULL").where("in_stock IS NOT NULL").where("in_stock != ''")
    @articles.each do |article|
      article_warn_on = article.article_group.present? ? article.article_group.warn_on : 10
      a = article.old_stock.to_f
      b = article.in_stock.to_f
      if article.in_stock.split(".").size > 1
        baan_vstk = (BigDecimal(article.old_stock) - BigDecimal(article.in_stock)) * -1
      else
        baan_vstk = (Integer(article.old_stock) - Integer(article.in_stock)) * -1
      end
      a_b_difference = a - b < 0 ? (a - b * -1) : (a - b)
      if a_b_difference >= ((a / 100) * article_warn_on)
        article.update_attributes(:should_be_checked => true, :baan_vstk => baan_vstk, :baan_vstr => baan_vstk)
      else
        article.update_attributes(:should_be_checked => false, :baan_vstk => baan_vstk, :baan_vstr => baan_vstk)
      end
    end
  end
  
end
