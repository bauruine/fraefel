class PurchasePositionPdfGenerator
  @queue = :purchase_position_pdf_generator_queue
  
  def self.perform(user_id, pdf_report_id)
    #Generate PDF and save...
    @user = User.where(:id => user_id).first
    @pdf_report = PdfReport.where(:id => pdf_report_id).first
    @crypted_file_name = Digest::MD5.hexdigest("#{@user.object_id}_#{Time.now}").concat(".pdf")
    @file_path = "public/pdfs/".concat(@crypted_file_name)
    @pdf = PurchasePositionDocument.new
    
    if @pdf.render_file(@file_path)
      # should send user js code to download PDF
      # PdfReport.where(:user_id => @user.id).destroy_all
      @pdf_report.update_attributes(:type => "purchase_position", :report_file_name => @crypted_file_name, :report_file_path => @file_path, :saved_local => false)
      
      ######## PUBLISH THROUGH FAYE ########
      PrivatePub.publish_to("/pdf_reports/#{@user.username}", "$('div#flash_notice[data-loader_id]').remove();$('div#flash_notice[data-id=#{@pdf_report.id}]').show();")
      ######## EO PUBLISHING ########
      
    else
      puts "file not created"
      # inform user that something went wrong...
    end
  end
end