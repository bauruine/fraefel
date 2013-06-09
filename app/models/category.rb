class Category < ActiveRecord::Base
  has_many :customers, :class_name => "Customer", :foreign_key => "category_id"
  has_many :addresses, :class_name => "Address", :foreign_key => "category_id"
  has_many :delivery_rejections, :class_name => "DeliveryRejection", :foreign_key => "category_id"
  has_many :html_contents, :class_name => "HtmlContent", :foreign_key => "category_id"

  CATEGORIZABLE_ITEMS = ['delivery_rejection', 'customer', 'address', 'purchase_order', 'html_content']

  after_create :update_import_category

  def self.create_from_raw_data(arg)

    category_attributes = Hash.new
    category_attributes.merge!(:title => arg.attributes["baan_81"])
    category_attributes.merge!(:categorizable_type => "purchase_order")

    category = Category.where(:title => category_attributes[:title], :categorizable_type => category_attributes[:categorizable_type]).first
    category ||= Category.new(category_attributes)

    if category.new_record?
      category.save
    else
      category.attributes = category_attributes
      if category.changed?
        category.save
      end
    end
  end

  protected

  def update_import_category
    import_category = Import::Category.find(:unique_id => Digest::MD5.hexdigest(%Q(#{self.title}-purchase_order))).first
    unless import_category.nil?
      import_category.update(:mapper_id => self.id.to_s)
    end
  end

end
