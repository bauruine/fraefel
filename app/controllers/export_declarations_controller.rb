# encoding: utf-8

class ExportDeclarationsController < FraefelController
  require 'csv'
  def index
    @uniq_eori = []
    @export_declarations = []
    CSV.foreach("import/csv/export_declarations/export_SpediListe.csv", {:col_sep => ";", :headers => :first_row}) do |row|
      @export_declarations << {:eori => row[17], :vk_auftrag => row[2], :vk => row[3], :vk_position => row[4], :lieferadresse => row[5], :liefertermin => row[18]}
      @uniq_eori << row[17]
    end
  end

  def show
    @eori = params[:id].delete(' ')
    @uniq_vk_auftrag = []
    @export_declarations = []
    CSV.foreach("import/csv/export_declarations/export_SpediListe.csv", {:col_sep => ";", :headers => :first_row}) do |row|
      if row[17].to_s.delete(' ') == @eori
        @export_declarations << {:zoll_position_nr => row[0], :zoll_position_beschreibung => row[1], :we_datum => row[19], :vk_auftrag => row[2], :vk => row[3], :vk_position => row[4], :lieferadresse => row[5], :liefertermin => row[18]}
        @uniq_vk_auftrag << row[2]
      end
    end
  end
end
