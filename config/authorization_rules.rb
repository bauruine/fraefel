authorization do
  role :admin do
    has_permission_on [:articles], :to => [:show, :index, :edit, :edit_multiple, :update_multiple, :search_for, :get_results_for, :calculate_difference_for, :export]
    has_permission_on [:roles, :users], :to => [:index, :show, :new, :create, :edit, :update, :destroy]
    has_permission_on [:cargo_lists], :to => [:recalculate, :show, :index, :controll_invoice, :collective_invoice, :calculate_cargo_list, :print_lebert, :search_for, :new, :create, :edit, :update, :assign_pallets, :remove_pallets]
    has_permission_on [:pallets], :to => [:show, :ajax_show, :index, :search_for, :assign_positions, :remove_positions, :edit, :update]
    has_permission_on [:purchase_orders], :to => [:show, :index, :search_for, :print_pallets, :edit, :update, :import_orders, :destroy_multiple, :index_beta]
    has_permission_on [:purchase_positions], :to => [:index, :search_for, :edit, :update, :index_beta]
    has_permission_on [:baan_imports], :to => [:index, :new, :create, :edit, :update, :import, :destroy_all]
  end

  role :inventar do
    has_permission_on [:articles], :to => [:show, :index, :edit, :edit_multiple, :update_multiple, :search_for, :get_results_for, :calculate_difference_for]
  end

  role :inventar_admin do
    has_permission_on [:articles], :to => [:show, :index, :edit, :edit_multiple, :update_multiple, :search_for, :get_results_for, :calculate_difference_for]
  end

  role :admin_view do
    has_permission_on [:cargo_lists], :to => [:show, :index, :controll_invoice, :collective_invoice, :calculate_cargo_list, :print_lebert, :search_for]
    has_permission_on [:pallets], :to => [:show, :ajax_show, :index, :search_for]
    has_permission_on [:purchase_orders], :to => [:show, :index, :search_for, :print_pallets]
    has_permission_on [:purchase_positions], :to => [:index, :search_for]
    has_permission_on [:users], :to => [:index]
  end

  role :verkauf do
    has_permission_on [:cargo_lists], :to => [:recalculate, :show, :index, :controll_invoice, :collective_invoice, :calculate_cargo_list, :print_lebert, :search_for, :new, :create, :edit, :update, :assign_pallets, :remove_pallets]
    has_permission_on [:pallets], :to => [:show, :ajax_show, :index, :search_for, :assign_positions, :remove_positions, :edit, :update]
    has_permission_on [:purchase_orders], :to => [:show, :index, :search_for, :print_pallets, :edit, :update, :import_orders]
    has_permission_on [:purchase_positions], :to => [:index, :search_for, :edit, :update]
    has_permission_on [:baan_imports], :to => [:index, :new, :create, :edit, :update, :import, :destroy_all]
  end

  role :verkauf_admin do
    has_permission_on [:purchase_orders], :to => [:destroy_multiple]
  end

  role :verkauf_view do
    has_permission_on [:cargo_lists], :to => [:show, :index, :controll_invoice, :collective_invoice, :calculate_cargo_list, :print_lebert, :search_for]
    has_permission_on [:pallets], :to => [:show, :ajax_show, :index, :search_for]
    has_permission_on [:purchase_orders], :to => [:show, :index, :search_for, :print_pallets]
    has_permission_on [:purchase_positions], :to => [:index, :search_for]
  end

  role :admin_beta do
    has_permission_on [:delivery_rejections], :to => [:index, :show, :new, :create, :edit, :update, :destroy]
  end

  role :delivery_rejection_admin do
    has_permission_on [:delivery_rejections], :to => [:index, :show, :new, :create, :edit, :update, :destroy, :assign_positions, :remove_positions, :search]
  end

  role :delivery_rejection_show do
    has_permission_on [:delivery_rejections], :to => [:index, :show]
  end

  role :guest do
    has_permission_on :user_sessions, :to => [:new, :create]
  end

end
