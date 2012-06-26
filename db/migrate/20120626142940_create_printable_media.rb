class CreatePrintableMedia < ActiveRecord::Migration
  def self.up
    create_table :printable_media do |t|
      t.string :title
    end
    
    PrintableMedia.create(:title => "proforma_invoice")
    PrintableMedia.create(:title => "transport_assignment")
  end

  def self.down
    drop_table :printable_media
  end
end
