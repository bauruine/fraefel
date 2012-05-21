class PdfReportsController < ApplicationController
  def show
    @pdf_report = PdfReport.where(:id => params[:id])
    @pdf = File.open(@pdf_report.first.report_file_path)
    
    respond_to do |format|
      format.html do
        send_data @pdf.read, :filename => "report.pdf", :type => "application/pdf"
      end
    end
  end
  
  def create
    @pdf_report = User.current.pdf_reports.create
    Resque.enqueue(PurchasePositionPdfGenerator, User.current.id, @pdf_report.id)
    
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @pdf_report = PdfReport.where(:id => params[:id])
    @pdf_report.first.destroy
    
    respond_to do |format|
      format.js
    end
  end
  
end
