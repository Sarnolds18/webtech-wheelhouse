Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
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
      resources :services, only: [ :index, :show, :create ]
      resources :repairs, only: [ :index, :show ]

      # Last: any other path or verb under /api/v1 answers the JSON 404, not Rails' HTML page.
      match "*path", to: "base#route_not_found", via: :all, format: false
    end
  end
end
