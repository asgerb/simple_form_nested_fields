Rails.application.routes.draw do
  resources :my_docs
  root 'my_docs#index'
end
