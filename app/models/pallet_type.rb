class PalletType < ActiveRecord::Base
  has_many :pallets
  
  def self.calculate_brutto_quantity(cargo_list_id, *args)
    args = args.first || {}
    self.includes(:pallets => :cargo_list).where("cargo_lists.id = ?", cargo_list_id).where(args).sum("pallet_types.count_as")
  end
  
  def self.calculate_brutto_weight(cargo_list_id, *args)
    args = args.first || {}
    self.calculate_brutto_quantity(cargo_list_id, args) * 20
  end
end
