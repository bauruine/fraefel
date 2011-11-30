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
  
  def edit_multiple
    @articles = Article.where(:rack_group_number => params[:rack_group_number])
  end
  
  def update_multiple
    @articles = Article.update(params[:articles].keys, params[:articles].values)
    redirect_to(articles_url)
  end
  
  def search_for
  end
  
  def get_results_for
    redirect_to(edit_multiple_articles_path(:rack_group_number => params[:rack_group_number]))
  end
end
