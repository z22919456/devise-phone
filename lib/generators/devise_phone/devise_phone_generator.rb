module Devise
  module Generators
    class DevisePhoneGenerator < Rails::Generators::NamedBase
      namespace 'devise_phone'

      desc 'Add phone, otp, prefix ... etc, attriables in the given model and generate migration'

      def inject_devise_phone_confirmable_content
        path = File.join('app', 'models', "#{file_path}.rb")
        inject_into_file(path, 'phone_confirmable, :', after: 'devise :') if File.exist?(path)
      end

      hook_for :orm
    end
  end
end
