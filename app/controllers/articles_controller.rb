class ArticlesController < ApplicationController
  filter_access_to :all
  
  def show
    
  end
  
  def index
    @search = Article.where(:considered => true).search(params[:search])
    @articles = @search.order("rack_group_number ASC, rack_root_number ASC, rack_part_number ASC, rack_tray_number ASC, rack_box_number ASC")
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
            :right => "#{Time.now}",
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
    @articles = Article.where(:considered => true).where(:rack_group_number => params[:rack_group_number])
  end
  
  def update_multiple
    @articles = Article.update(params[:articles].keys, params[:articles].values)
    Resque.enqueue(BaanCalculator, params[:rack_group_number])
    redirect_to(articles_url)
  end
  
  def search_for
  end
  
  def get_results_for
    redirect_to(edit_multiple_articles_path(:rack_group_number => params[:rack_group_number]))
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
            :right => "#{Time.now}",
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
    CSV.open(csv_file_full_path, "wb") do |csv|
      Article.where(:considered => true).order("baan_pono ASC").each do |article|
        baan_orno = article.baan_orno.present? ? article.baan_orno : ""
        baan_cntn = article.baan_cntn.present? ? article.baan_cntn : ""
        baan_pono = article.baan_pono.present? ? article.baan_pono : ""
        article_depot = article.baan_acces_id.split("x")[1].present? ? article.baan_acces_id.split("x")[1] : "   "
        baan_loca = article.baan_loca.present? ? article.baan_loca : "          "
        baan_clot = article.baan_clot.present? ? article.baan_clot : "                "
        baan_qstk = article.baan_qstk.present? ? "#{article.baan_qstk}" : "0"
        baan_qstr = article.baan_qstr.present? ? "#{article.baan_qstr}" : "0"
        baan_cstk = article.in_stock.present? ? "#{article.in_stock}" : "0"
        baan_csts = article.baan_csts.present? ? "#{article.baan_csts}" : ""
        baan_recd = article.baan_recd.present? ? "#{article.baan_recd}" : ""
        csv << ["#{baan_orno}", "#{baan_cntn}", "#{baan_pono}", "#{article_depot}", "#{baan_loca}", "#{article.baan_item}", "#{baan_clot}", "#{article.baan_date}", "#{article.baan_stun}", "#{baan_qstk}", "#{baan_qstr}", "#{baan_cstk}", "#{baan_cstk}", "14", "15", "#{baan_csts}", "#{Time.now.to_i}", "#{baan_recd}", "#{article.baan_reco}", "#{article.baan_appr}", "#{article.baan_cadj}"]
      end
    end
    csv_file = File.open(csv_file_full_path)
    send_file(csv_file, :filename => "file.csv", :type => "text/csv")
    #redirect_to(:back)
  end
end
