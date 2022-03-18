require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class DevisePhoneGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path('./templates', __dir__)

      def copy_devise_migration
        migration_template 'add_resrouce_phone_confirmation_column_migration.rb', "db/migrate/devise_add_#{table_name}_phone_confirmations.rb",
                           migration_version: migration_version
        migration_template 'create_otp_verifiecations_migration.rb', "db/migrate/devise_create_otp_verifications.rb",
                           migration_version: migration_version
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if Rails::VERSION::MAJOR >= 5
      end
    end
  end
end
