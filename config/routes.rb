Rails.application.routes.draw do
  get 'home/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  scope module: 'deploy' do
    get  'deploy/authorize/callback', to: 'authorize#callback'
    get  'deploy/authorize', to: 'authorize#authorize'
  end
  
  get 'contact' => 'home#contact'
  get 'wheretobuy' => 'home#wheretobuy'
  get 'whyatopica' => 'home#whyatopica'
  get 'worming' => 'home#worming'
  get 'about2' => 'about#about2'
  get 'about3' => 'about#about3'
  get 'about4' => 'about#about4'
  get 'info/diagnosis' => 'info#diagnosis'
  get 'info/faq' => 'info#faq'
  get 'info/infographic' => 'info#infographic'
  get 'info/resources' => 'info#resources'
  get 'info/dosingtable' => 'info#dosingtable'
  get 'info/popup' => 'info#popup'
  get 'media/video' => 'media#video'
  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
