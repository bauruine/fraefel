authorization do
  role :admin do
    has_permission_on [:roles, :users], :to => [:index, :show, :new, :create, :edit, :update, :destroy]
    has_permission_on [:cargo_lists], :to => [:show, :index, :controll_invoice, :collective_invoice, :calculate_cargo_list, :print_lebert, :search_for, :new, :create, :edit, :update, :assign_pallets, :remove_pallets]
    has_permission_on [:pallets], :to => [:show, :ajax_show, :index, :search_for, :assign_positions, :remove_positions, :edit, :update]
    has_permission_on [:purchase_orders], :to => [:show, :index, :search_for, :print_pallets, :edit, :update, :import_orders]
    has_permission_on [:purchase_positions], :to => [:index, :search_for, :edit, :update]
  end
  
  role :admin_view do
    has_permission_on [:cargo_lists], :to => [:show, :index, :controll_invoice, :collective_invoice, :calculate_cargo_list, :print_lebert, :search_for]
    has_permission_on [:pallets], :to => [:show, :ajax_show, :index, :search_for]
    has_permission_on [:purchase_orders], :to => [:show, :index, :search_for, :print_pallets]
    has_permission_on [:purchase_positions], :to => [:index, :search_for]
    has_permission_on [:users], :to => [:index]
  end
  
  role :verkauf do
    has_permission_on [:cargo_lists], :to => [:show, :index, :controll_invoice, :collective_invoice, :calculate_cargo_list, :print_lebert, :search_for, :new, :create, :edit, :update, :assign_pallets, :remove_pallets]
    has_permission_on [:pallets], :to => [:show, :ajax_show, :index, :search_for, :assign_positions, :remove_positions, :edit, :update]
    has_permission_on [:purchase_orders], :to => [:show, :index, :search_for, :print_pallets, :edit, :update, :import_orders]
    has_permission_on [:purchase_positions], :to => [:index, :search_for, :edit, :update]
  end
  
  role :guest do
    has_permission_on :user_sessions, :to => [:new, :create]
  end
  
end