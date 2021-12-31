Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'api/v1/users/sessions',
    registrations: 'api/v1/users/registrations'
  }
  # namespace :api do
  #   scope :v1 do
  #     mount_devise_token_auth_for 'User', at: 'auth'
  #   end
  # end


  namespace :api do
    namespace :v1 do


      devise_for :users, controllers: { sessions: 'api/v1/sessions', registrations: 'api/v1/registrations' }
      resources :companies do
        collection do
          delete :destroy_all
        end
        member do
          get :employees
          get :resyncing
          put :sync
        end
      end
      devise_scope :user do
        put 'change_password', to: 'registrations#change_password'
        post 'forgot_password', to: 'registrations#forgot_password'
        post 'reset_password', to: 'registrations#reset_password'
        put 'update_password', to: 'registrations#update_password'
      end
      get 'search', to: 'linked_data#search'
      get 'company_profile', to: 'linked_data#company_info'
      get 'sales_qi_linkedin', to: 'linked_data#sales_qi_linkedin'
      get 'resync', to: 'linked_data#resync'
      get 'export_csv', to: 'linked_data#export_csv'
    end
  end
end
