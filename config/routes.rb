Spree::Core::Engine.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    namespace :solidus_signifyd do
      post '/orders', to: 'orders#update'
    end
  end
end
