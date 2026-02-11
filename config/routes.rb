Rails.application.routes.draw do
  get "home/index"
  devise_for :users
  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })

  root to: "home#index"

  resources :locations, only: [:index] do
    get :cities, on: :collection
  end
end
