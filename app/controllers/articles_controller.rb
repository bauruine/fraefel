class ArticlesController < ApplicationController
  filter_access_to :all
  
  def show
    
  end
  
  def index
    @search = Article.where(:considered => true).search(params[:search])
    @articles = @search.order("rack_group_number ASC, rack_root_number ASC, rack_part_number ASC, rack_tray_number ASC, rack_box_number ASC, article_code ASC")
    respond_to do |format|
      format.html
      format.pdf do
        render( 
          :pdf => "Zaehlliste-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Portrait',
          :encoding => 'UTF-8',
          :header => {
            :left => "Fraefel AG",
            :right => "#{Time.now.to_formatted_s(:swiss_date)}",
            :line => true,
            :spacing => 2
          },
          :footer => {
            :left => "#{articles_url(:format => :pdf)}",
            :right => "Seite [page] / [topage]",
            :line => true
          }
        )
      end
    end
    
  end
  
  def edit
    
  end
  
  def edit_multiple
    if params[:baan_acces_code].present? && !params[:rack_group_number].present?
      rack_group_number = Article.find_by_baan_acces_id(params[:baan_acces_code]).present? ? Article.find_by_baan_acces_id(params[:baan_acces_code]).rack_group_number : nil
      rack_root_number = Article.find_by_baan_acces_id(params[:baan_acces_code]).present? ? Article.find_by_baan_acces_id(params[:baan_acces_code]).rack_root_number : nil
      @articles = Article.where(:considered => true).where(:rack_group_number=> rack_group_number, :rack_root_number => rack_root_number)
    elsif params[:rack_group_number].present? && params[:rack_root_number].present?
      @articles = Article.where(:considered => true).where(:rack_group_number => params[:rack_group_number], :rack_root_part_number => params[:rack_root_number])
    else
      @articles = nil
    end
  end
  
  def update_multiple
    @articles = Article.update(params[:articles].keys, params[:articles].values)
    Resque.enqueue(BaanCalculator, @articles.first.rack_group_number)
    redirect_to(articles_url(:search => {:rack_group_number_equals => @articles.first.rack_group_number, :rack_root_part_number_equals => @articles.first.rack_root_part_number}))
  end
  
  def search_for
  end
  
  def get_results_for
    redirect_to(edit_multiple_articles_path(:rack_group_number => params[:rack_group_number], :baan_acces_code => params[:baan_acces_code], :rack_root_number => params[:rack_root_number]))
  end
  
  def calculate_difference_for
    @articles = Article.where(:rack_group_number => params[:group], :should_be_checked => true)
    
    respond_to do |format|
      format.pdf do
        render( 
          :pdf => "Abweichung-Gruppe#{params[:group]}-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Portrait',
          :encoding => 'UTF-8',
          :header => {
            :left => "Fraefel AG",
            :right => "#{Date.today.to_formatted_s(:swiss_date)}",
            :line => true,
            :spacing => 2
          },
          :footer => {
            :left => "#{articles_url(:format => :pdf)}",
            :right => "Seite [page] / [topage]",
            :line => true
          }
        )
      end
    end
  end
  
  def export
    # generates ugly csv for baan
    # should make a method to fill with empty spaces...
    csv_file_full_path = Rails.public_path + "/csv/file.csv"
    CSV.open(csv_file_full_path, "wb", {:col_sep => ";"}) do |csv|
      Article.where(:considered => true).order("baan_pono ASC").each do |article|
        baan_orno = article.baan_orno.present? ? article.baan_orno : ""
        baan_cntn = article.baan_cntn.present? ? article.baan_cntn : ""
        baan_pono = article.baan_pono.present? ? article.baan_pono : ""
        article_depot = article.baan_acces_id.split("x")[1].present? ? article.baan_acces_id.split("x")[1] : "0"
        baan_loca = article.baan_loca.present? ? article.baan_loca : "          "
        baan_clot = article.baan_clot.present? ? article.baan_clot : "                "
        baan_date = article.baan_date.present? ? article.baan_date : article.baan_date.to_i
        baan_qstk = article.baan_qstk.present? ? "#{article.baan_qstk}" : "0"
        baan_qstr = article.baan_qstr.present? ? "#{article.baan_qstr}" : "0"
        baan_cstk = article.in_stock.present? ? "#{article.in_stock}" : "0"
        baan_csts = article.baan_csts.present? ? "#{article.baan_csts}" : "0"
        baan_recd = article.baan_recd.present? ? "#{article.baan_recd}" : ""
        baan_reco = article.baan_reco.present? ? "#{article.baan_reco}" : "0"
        baan_appr = article.baan_appr.present? ? "#{article.baan_appr}" : "0"
        baan_cadj = nil
        csv << ["#{baan_orno}", "#{baan_cntn}", "#{baan_pono}", "#{article_depot}", "#{baan_loca}", "#{article.baan_item}", "#{baan_clot}", "#{baan_date}", "#{article.baan_stun}", "#{baan_qstk}", "#{baan_qstr}", "#{baan_cstk}", "#{baan_cstk}", "#{article.baan_vstk}", "#{article.baan_vstr}", "#{baan_csts}", "#{Time.now.to_i}", "#{baan_recd}", "#{baan_reco}", "#{baan_appr}", nil]
      end
    end
    csv_file = File.open(csv_file_full_path)
    send_file(csv_file, :filename => "file.csv", :type => "text/csv")
    #redirect_to(:back)
  end
end
