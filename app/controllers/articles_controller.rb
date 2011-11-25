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
            :left => "#{articles_url(@pallet, :format => :pdf)}",
            :right => "Seite [page] / [topage]",
            :line => true
          }
        )
      end
    end
    
  end
  
end
