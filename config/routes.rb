Rails.application.routes.draw do
  root to: 'words#index'

  get 'words/search', to: 'words#search', as: :search
end
