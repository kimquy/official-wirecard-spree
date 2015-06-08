Spree::Core::Engine.routes.append do
#  post '/wirecard_checkout_page', :to => "wirecard_checkout_page#express", :as => :wirecard_checkout_page
  post '/wirecard_checkout_page/return', :to => "wirecard_checkout_page#return", :as => :wirecard_checkout_page_return
  post '/wirecard_checkout_page/confirm', :to => "wirecard_checkout_page#confirm", :as => :wirecard_checkout_page_confirm
end

Spree::Core::Engine.routes.draw do
  # Add your extension routes here

  resources :orders do
    resource :checkout, :controller => 'checkout' do
      member do
        post :wirecard_checkout_page_return
      end
    end
  end
end
