Fraefel::Application.routes.draw do
  
  mount Resque::Server.new, :at => "/resque"
  
  resources :password_resets, :only => [ :new, :create, :edit, :update ]
  
  resources :articles do
    collection do
      get 'search_for'
      get 'get_results_for'
      get 'edit_multiple'
      put 'update_multiple'
      get 'calculate_difference_for'
      get 'export'
    end
  end
  
  resources :users
  
  resources :addresses
  
  resources :pdf_reports
  
  resources :departments
  
  resources :shifting_reasons
  
  resources :shipping_routes
  
  resources :time_shiftings

  resource :dashboard, :only => [:show]
  
  resources :microsoft_databases

  resources :user_sessions
  
  resources :roles
  
  resources :categories
  
  resources :statuses
  
  resources :customers
  
  resources :export_declarations
  
  resources :pallet_purchase_position_assignments
  
  resources :versions, :only => [:update, :destroy]
  
  resources :baan_imports do
    member do
      get 'import'
    end
  end
  
  resources :purchase_positions do
    collection do
      get 'search_for'
      get 'index_beta'
    end
  end
  
  resources :purchase_orders do
    resources :time_shiftings
    member do
      get 'print_pallets'
    end
    collection do
      get 'import_orders'
      get 'search_for'
      delete 'destroy_multiple'
      get 'index_beta'
    end
  end
  
  resources :pallets do
    member do
      delete 'remove_positions'
      get 'ajax_show'
    end
    collection do
      post 'assign_positions'
      delete 'delete_empty'
      get 'search_for'
    end
  end
  
  resources :cargo_lists do
    collection do
      post 'assign_pallets'
      post 'remove_pallets'
      get 'search_for'
    end
    member do
      get 'print_pallets'
      get 'collective_invoice'
      get 'print_lebert'
      get 'controll_invoice'
    end
  end
  
  resources :delivery_rejections do
    member do
      post 'assign_positions'
      delete 'remove_positions'
    end
    collection do
      post 'search'
    end
  end
  
  resources :purchase_order_pallet_assignments

  resources :stocktakings

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  root :to => "dashboards#show"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
