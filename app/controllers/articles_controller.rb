class ArticlesController < ApplicationController
  def show
    
  end
  
  def index
    @search = Article.search(params[:search])
    @articles = @search
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
  
  def search_for
  end
  
  def get_results_for
    redirect_to(articles_path(:search => {:rack_group_number_equals => params[:rack_group_number]}))
  end
end
