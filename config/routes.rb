Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "visiting", to: "pages#visiting", as: :visiting
  get "about", to: "pages#about", as: :about

  resources :customers, only: [ :index, :show ]
  resources :bikes, only: [ :index, :show ]
  resources :repairs, only: [ :index, :show ]
  resources :services, only: [ :index, :show ]
  resources :mechanics, only: [ :index, :show ]
end
