# frozen_string_literal: true

Rails.application.routes.draw do
  root "trays#index"

  resources :trays do
    resources :cubes do
      resources :faces do
        collection do
          post :positions
        end
      end

      collection do
        post :positions
        delete :destroy_all, path: ""
      end
    end
  end
end
