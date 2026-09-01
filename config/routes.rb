Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "services", to: "pages#services", as: :services
  get "visiting", to: "pages#visiting", as: :visiting
  get "about", to: "pages#about", as: :about
end