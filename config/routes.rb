Fraefel::Application.routes.draw do
  
  mount Resque::Server.new, :at => "/resque"
  
  resources :articles do
    collection do
      get 'search_for'
      get 'get_results_for'
      get 'edit_multiple'
      put 'update_multiple'
    end
  end
  
  resources :users

  resources :microsoft_databases

  resources :user_sessions
  
  resources :roles
  
  resources :customers
  
  resources :export_declarations
  
  resources :versions, :only => [:update, :destroy]
  
  resources :baan_imports do
    member do
      get 'import'
    end
  end
  
  resources :purchase_positions do
    collection do
      get 'search_for'
    end
  end
  
  resources :purchase_orders do
    member do
      get 'print_pallets'
    end
    collection do
      get 'import_orders'
      get 'search_for'
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
  root :to => "purchase_orders#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
