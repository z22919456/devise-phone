module ActionDispatch::Routing
  class Mapper
    protected

    def devise_phone_confirmation(mapping, controllers)
      resource :phone_confirmation, only: %i[new create edit update],
                                     path: mapping.path_names[:phone_confirmation], controller: controllers[:phone_confirmations]
    end
  end
end
