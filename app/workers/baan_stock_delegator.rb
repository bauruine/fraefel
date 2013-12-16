class BaanStockDelegator

  include Sidekiq::Worker

  sidekiq_options queue: "baan_stock_delegator_queue"
  sidekiq_options retry: false

  def perform(baan_import_id, importer_klass)
    if importer_klass.nil?
      return
    end
    
    case importer_klass
    when "Inventar-Baan-Artikel"
      Article.import(baan_import)
    when "Inventar-Lager-Adresse"
      Depot.import(baan_import)
    when "Inventar-Lager-Zone"
      Article.import_extras(baan_import)
    when "Inventar-Baan-Artikel-Gruppe"
      ArticleGroup.import(baan_import)
    when "Inventar-Baan-Artikel-Preis-Gruppe"
      Article.import_extras_1(baan_import)
    when "Inventar-BaanCSV"
      Article.import_baan_file(baan_import)
    end
  end
  
end
