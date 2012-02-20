# encoding: utf-8 
class DeliveryRejection < ActiveRecord::Base
  belongs_to :status, :class_name => "Status", :foreign_key => "status_id"
  belongs_to :category, :class_name => "Category", :foreign_key => "category_id"
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  #belongs_to :cargo_list, :class_name => "CargoList", :foreign_key => "cargo_list_id"
  belongs_to :address, :class_name => "Address", :foreign_key => "address_id"
  belongs_to :referee, :class_name => "Referee", :foreign_key => "referee_id"
  
  has_many :comments, :as => :commentable  
  
  has_many :transport_issues
  has_many :purchase_positions, :through => :transport_issues, :foreign_key => "purchase_position_id", :source => :purchase_position
  has_many :pallets, :class_name => "Pallet", :foreign_key => "delivery_rejection_id"
  has_many :addresses, :class_name => "Address", :foreign_key => "delivery_rejection_id"
  has_many :cargo_list_delivery_rejection_assignments
  has_many :cargo_lists, :through => :cargo_list_delivery_rejection_assignments
  
  accepts_nested_attributes_for :comments, :address, :addresses, :referee
  
  validates_presence_of :category, :message => "Es wurde kein Grund angegeben"
  validates_presence_of :status, :message => "Es wurde kein Status gewählt"
  validates_presence_of :customer_company, :message => "Es wurde kein Handelspartner angegeben"
  validates_presence_of :f_cargo_list_ids, :message => "Es wurde keine Versand NR angegeben"
  validates_presence_of :discount, :message => "Es wurde kein Warenwert definiert."
  
  after_update :check_assigned_positions
  
  def customer_company
    customer.try(:company)
  end

  def customer_company=(name)
    self.customer = Customer.find_by_company(name) if name.present?
  end
  
  def f_cargo_list_ids
    self.cargo_list_ids.join(", ")
  end
  
  def f_cargo_list_ids=(string_with_ids)
    self.cargo_list_ids = string_with_ids.delete(" ").split(",") if string_with_ids.present?
  end
  
  private
    def check_assigned_positions
      if self.discount.present? and PurchasePosition.where("delivery_rejections.id = ?", self.id).includes(:pallets => :delivery_rejection).present?
        PalletPurchasePositionAssignment.where("delivery_rejections.id = ?", self.id).includes(:pallet => :delivery_rejection).each do |pppa|
          pppa.update_attribute(:reduced_price, ((pppa.amount / 100) * self.discount))
        end
      end
    end
end
