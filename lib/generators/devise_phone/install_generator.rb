module DevisePhone
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      desc 'Install phone confirmation'

      def copy_initializer
        template('devise_phone.rb',
                 'config/initializers/devise_phone.rb')
      end
    end
  end
end
