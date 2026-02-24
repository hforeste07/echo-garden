Rails.application.routes.draw do
  get "gardens/index"
  get "gardens/show"
  devise_for :users

  root to: "home#index"

  get "dashboard", to: "dashboard#index"

  resources :gardens do
    resources :garden_plots, only: [:create, :update, :destroy]
  end

  resources :plants, only: [:index, :show]

  resources :locations, only: [:index] do
    get :cities, on: :collection
  end
end
