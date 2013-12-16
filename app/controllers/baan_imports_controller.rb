# encoding: utf-8

class BaanImportsController < FraefelController
  filter_access_to :all

  def index
    @baan_imports = BaanImport.order("id DESC")
    @baan_updator_queue = Sidekiq::Queue.new("baan_updator_queue")
    @baan_importer_queue = Sidekiq::Queue.new("baan_importer_queue")
    @baan_delegator_queue = Sidekiq::Queue.new("baan_delegator_queue")
    @baan_jaintor_queue = Sidekiq::Queue.new("baan_jaintor_queue")
    @stats = Sidekiq::Stats.new
  end

  def new
    @baan_import = BaanImport.new
    respond_to do |format|
      format.xml
      format.html
    end
  end

  def create
    @baan_import = BaanImport.new(params[:baan_import])

    if @baan_import.baan_upload.present?
      file_name = File.basename(@baan_import.baan_upload_file_name, File.extname(@baan_import.baan_upload_file_name))
      file_name = file_name.downcase.chomp.lstrip.rstrip

      if file_name == "baanread_versand_alle" || file_name == "baanread_versand_selektiv"
        @baan_import.baan_import_group_id = BaanImportGroup.where(:title => "Versand").first.try(:id)
      elsif file_name == "baanread_versand_alle_verrechnet"
        @baan_import.baan_import_group_id = BaanImportGroup.where(:title => "Versand-Verrechnet").first.try(:id)
      elsif file_name == "baanread_versand_storniert"
        @baan_import.baan_import_group_id = BaanImportGroup.where(:title => "Versand-Storniert").first.try(:id)
      elsif file_name == "inventar_baanartikel_artikel_gruppe"
        @baan_import.baan_import_group_id = BaanImportGroup.where(:title => "Inventar-Baan-Artikel-Gruppe").first.try(:id)
      elsif file_name == "inventar_baanartikel_preis_gruppe"
        @baan_import.baan_import_group_id = BaanImportGroup.where(:title => "Inventar-Baan-Artikel-Preis-Gruppe").first.try(:id)
      elsif file_name == "inventar_baanartikel"
        @baan_import.baan_import_group_id = BaanImportGroup.where(:title => "Inventar-Baan-Artikel").first.try(:id)
      elsif file_name == "inventar_lager_adresse"
        @baan_import.baan_import_group_id = BaanImportGroup.where(:title => "Inventar-Lager-Adresse").first.try(:id)
      elsif file_name == "inventar_lagerzone"
        @baan_import.baan_import_group_id = BaanImportGroup.where(:title => "Inventar-Lager-Zone").first.try(:id)
      elsif file_name == "inventar_baancsv"
        @baan_import.baan_import_group_id = BaanImportGroup.where(:title => "Inventar-BaanCSV").first.try(:id)
      else
        @baan_import.baan_import_group_id = nil
      end
    end

    if @baan_import.save
      redirect_to(baan_imports_url, :notice => "CSV wurde erfolgreich gespeichert.")
    else
      flash[:error] = "CSV konnte nicht gespeichert werden!"
      render 'new'
    end
  end

  def edit
    @baan_import = BaanImport.find(params[:baan_import])
  end

  def update
    @baan_import = BaanImport.find(params[:baan_import])
    if @baan_import.update_attributes(params[:baan_import])
      redirect_to :back
    else
      render 'edit'
    end
  end

  def destroy_all
    BaanImport.delete_all
    redirect_to(baan_imports_path, :notice => "Alle CSV Dateien wurden gelöscht.")
  end

  def import
    @baan_import = BaanImport.find(params[:id])
    @baan_import_group = BaanImportGroup.where(:id => @baan_import.baan_import_group_id).first
    
    if @baan_import_group.title.split("-")[0] == "Versand"
      BaanDelegator.perform_async(@baan_import.id, @baan_import_group.title)
    elsif @baan_import_group.title.split("-")[0] == "Inventar"
      BaanStockDelegator.perform_async(@baan_import.id, @baan_import_group.title)
    end
    
    redirect_to(baan_imports_url, :notice => "Import wurde gestartet.")
  end
end
