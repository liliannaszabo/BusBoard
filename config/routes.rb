Rails.application.routes.draw do
  get "/buses", to: "pages#index"
  get "/postcode/", to: "pages#postcode"
  root "pages#index"
end
