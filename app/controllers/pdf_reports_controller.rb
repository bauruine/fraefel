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
    # Resque.enqueue(PurchasePositionPdfGenerator, User.current.id, @pdf_report.id)
    
    @crypted_file_name = Digest::MD5.hexdigest("#{User.current.object_id}_#{Time.now}").concat(".pdf")
    @file_path = "public/pdfs/".concat(@crypted_file_name)
    @pdf_document = eval(params[:pdf_type]).new(params[:args_for_printing])
    
    @pdf_document.render_file(@file_path)
    @pdf_report.update_attributes(:pdf_type => params[:pdf_type], :report_file_name => @crypted_file_name, :report_file_path => @file_path, :saved_local => false)
    
    
    respond_to do |format|
      format.html do
        @pdf = File.open(@pdf_report.report_file_path)
        send_data @pdf.read, :filename => "report.pdf", :type => "application/pdf"
      end
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
