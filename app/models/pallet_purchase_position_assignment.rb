class PalletPurchasePositionAssignment < ActiveRecord::Base
  belongs_to :pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  belongs_to :purchase_position, :class_name => "PurchasePosition", :foreign_key => "purchase_position_id"
  
  def self.fix_amount_and_weight
    self.all.each do |p_p_p_a|
      if p_p_p_a.purchase_position.present?
        p_p_p_a.update_attributes(:weight => (p_p_p_a.purchase_position.weight_single * p_p_p_a.quantity), :amount => (p_p_p_a.purchase_position.amount * p_p_p_a.quantity))
      end
    end
  end
  
  def self.fix_quantity_for_cargo_list
    self.where("pallets.delivery_rejection_id IS NULL").includes(:pallet).each do |p_p_p_a|
      if p_p_p_a.purchase_position.present?
        p_p_p_a.update_attribute(:reduced_price, (p_p_p_a.purchase_position.amount * p_p_p_a.quantity))
      end
    end
  end
  
  def self.calculate_netto_weight(cargo_list_id, *args)
    args = args.first || {}
    self.includes(:pallet => :cargo_list).where("cargo_lists.id = ?", cargo_list_id).where(args).sum(:weight)
  end
  
  def self.calculate_brutto_weight(cargo_list_id, *args)
    args = args.first || {}
    self.calculate_netto_weight(cargo_list_id, args) + PalletType.calculate_brutto_weight(cargo_list_id)
  end
  
  def self.calculate_netto_amount(cargo_list_id, *args)
    args = args.first || {}
    self.includes(:pallet => :cargo_list).where("cargo_lists.id = ?", cargo_list_id).where(args).sum(:amount)
  end
  
  def self.calculate_tax(cargo_list_id, *args)
    args = args.first || {}
    ((self.calculate_netto_amount(cargo_list_id, args) / 100) * 19).round(2)
  end
  
  def self.calculate_brutto_amount(cargo_list_id, *args)
    args = args.first || {}
    self.calculate_netto_amount(cargo_list_id, args) + self.calculate_tax(cargo_list_id, args)
  end
  
end
