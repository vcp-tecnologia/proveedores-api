Rails.application.routes.draw do
  get 'productos', to: 'products#productos'
  get 'proveedores', to: 'products#proveedores'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
