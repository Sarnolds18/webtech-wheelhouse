Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "visiting", to: "pages#visiting", as: :visiting
  get "about", to: "pages#about", as: :about

  resources :customers
  resources :bikes
  resources :repairs do
    resources :photos, only: :destroy, module: :repairs
  end
  resources :services
  resources :mechanics
end
