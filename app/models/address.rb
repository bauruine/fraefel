class Address < ActiveRecord::Base
  belongs_to :category, :class_name => "Category", :foreign_key => "category_id"
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :referee, :class_name => "Referee", :foreign_key => "referee_id"
  
  def location_full
    "#{self.postal_code} #{self.city}"
  end
  
  def location_all_attributes
    if self.category.present?
      "#{self.category.title}: #{self.street}, #{self.postal_code} #{self.city}"
    else
      "#{self.street}, #{self.postal_code} #{self.city}"
    end
  end
  
  def valid_for_printing
    (self.postal_code.present? && self.city.present? && self.city.present?) ? true : false
  end
end
