# -*- encoding : utf-8 -*-
Cardsys::Application.routes.draw do 

  get "powers/index"

  get "powers/edit"

  resources :common_resource_details

  resources :rents

  resources :lockers do
    collection do
      get "list"
      get "autocomplete_num"
    end
    resources :rents
  end

  resources :categories
  resources :logs

  get "welcome/backup"
  delete "welcome/delete_backup"

  get "welcome/about"
  get "welcome/backup_db"

  get "reports/coach"
  get "reports/good_search"
  get "reports/income"
  get "reports/income_by_month"
  get "reports/good_type_day"
  get "reports/print_good_type_day"
  get "reports/member_cosume_detail"
  get "reports/court_usage"

  resources :member_card_granters,:only => :destroy do
    member do
      put :switch
    end
  end

  resources :vacations do
    member do
      put :switch_state
    end

  end

  resources :orders do
    member do
      put :change_state
      put :add_good
      post :sell
    end

    resources :order_items do
      collection do
        post :batch_update
      end
    end

    resources :balances do
      collection do 
        get :balanced
      end
    end

    resources :goods do
      collection do 
        get :goods
      end
    end
  end

  resources :balance_items do
    member do
      post :update_real_price
      post :update_discount_rate
    end
  end

  resources :balances do
    member do 
      get :print
    end

    collection do
      delete :destroy_good
      get :balanced
      get :unbalanced
      post :add_good
      post :change_li_real_total_price
      get :new_good_buy
      get :clear_goods
      post :create_good_buy
      get :member_by_member_card_serial_num
    end
  end

  resources :book_records do
    collection do
      get   :complete_for_members
      get   :complete_member_infos
      get   :recalculate_court_amount
      get   :advanced_new
      post  :advanced_create
      get   :complete_for_member_card
      get   :print
    end
    member do
      get  :agent
      get  :cancle_agent
      post :do_agent
      get  :advanced_edit 
      post :advanced_update
    end
  end
  
  resources :advanced_orders do
    member do
      get :cancle
    end
  end
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  resources :members do
    collection do
      post :search
      get :granter_new
      get :granter_delete
      get :granter_edit
      get :granter_index
      get :granter_show
      get :member_card_index
      get :autocomplete_name
      get :get_members
      get :autocomplete_card_serial_num
      get :member_card_bind_index
      post :member_card_bind_update
      get :member_card_recharge
      get :member_card_freeze
      get :member_card_bind_list
      get :getMemberCardNo
      get :advanced_search
    end

    member do
      get :member_cards_list
      put :switch_state
    end
  end

  resources :cards do
    member do
      get :bind
      put :switch_state
      get :default_card_serial_num
    end
  end

  resources :members_cards do
    collection do
      get :recharge
      get :recharge_form
      get :granter_form
      get :granters
      get :status
      get :status_html
      get :autocomplete_name
      get :autocomplete_card_serial_num
    end
    member do
      put :switch_state
    end
  end
  resources :coaches do 
    member do
      put :switch_state
    end

    collection do
      get :search
    end
  end
  
  resources :period_prices
  resources :common_resources do
    resources :common_resource_details

    collection do
      get :common_resource_detail_index
      get :power_index
      put :power_update
    end
  end
  resources :courts do
    collection do
      get :court_status_search
      get :coach_status_search
      get :court_record_detail
      get :coach_record_detail
    end
     member do
      put :switch_state
    end
  end

  resources :goods do
    member do
      put :front_store_update
      get :front_store_manage
      put :back_store_update
      get :back_store_manage
      put :switch_state
      post :add_to_cart
    end
    collection do
      get :change_status
      get :autocomplete_name
      get :autocomplete_good
      get :autocomplete_barcode
      get :goods
      get :find_goods
      get :front
      get :back
      get :select_for_cart
      get :by_category
      post :add_to_cart
      get :price
    end
  end


  resource :account, :controller => "users"
  resources :users do
    collection do
      get :autocomplete_user_name
      get :change_password
      post :change_pass
    end

    member do
      put :switch_state
    end
  end

  resource :user_session
  resources :powers

  resources :departments do
    member do
      get :department_power_index
      put :department_power_update
    end
  end
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
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
  #       get :recent, :on => :collection
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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match 'about' =>"welcome#about"
  match 'backup' =>"welcome#backup"
  match 'change_catena' =>"base#change_catena"
  match ':controller(/:action(/:id(.:format)))'
  match 'account' => "user#show"
  root :to => "orders#index"
end
