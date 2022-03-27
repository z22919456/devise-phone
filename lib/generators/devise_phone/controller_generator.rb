module DevisePhone
  module Generators
    class ControllerGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates/controllers', __dir__)

      desc <<-DESC.strip_heredoc
        Create inherited Devise controllers  in your app/controllers folder.
      DESC

      argument :scope, required: true,
                       desc: 'The scope to create controllers in, e.g. users, admins'

      def create_controllers
        @scope_prefix = scope.blank? ? '' : (scope.camelize + '::')

        %w[phone_confirmations].each do |name|
          template "#{name}_controller.rb",
                   "app/controllers/#{scope}/#{name}_controller.rb"
        end
      end

      def copy_initializer
        template('devise_phone.rb',
                 'config/initializers/devise_phone.rb')
      end
    end
  end
end
