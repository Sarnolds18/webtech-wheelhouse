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

  # The JSON API for programs that are not a browser. The version is a segment of the path, and a
  # program needs no form, so there is no new and no edit.
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :services, only: [ :index, :show ]
    end
  end
end
