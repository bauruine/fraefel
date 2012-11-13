authorization do
  role :admin do
    has_permission_on [:articles], :to => [:show, :index, :edit, :edit_multiple, :update_multiple, :search_for, :get_results_for, :calculate_difference_for, :export]
    has_permission_on [:roles, :users], :to => [:index, :show, :new, :create, :edit, :update, :destroy]
    has_permission_on [:baan_imports], :to => [:index, :new, :create, :edit, :update, :import]
  end
  
  role :inventar do
    has_permission_on [:articles], :to => [:show, :index, :edit, :edit_multiple, :update_multiple, :search_for, :get_results_for, :calculate_difference_for]
  end
  
  role :inventar_admin do
    has_permission_on [:articles], :to => [:show, :index, :edit, :edit_multiple, :update_multiple, :search_for, :get_results_for, :calculate_difference_for]
  end
  
  role :guest do
    has_permission_on :user_sessions, :to => [:new, :create]
  end
  
end