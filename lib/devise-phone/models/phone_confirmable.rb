module Devise
  module Models
    module PhoneConfirmable
      extend ActiveSupport::Concern

      included do
        attr_accessor :otp_check
      end

      def self.required_fields(_klass)
        %i[phone phone_confirmed_at otp_prefix otp phone_confirmation_otp_send_at]
      end

      def send_phone_confirmation_otp(params)
        generate_confirm_otp!(params)
        send_texter
      end

      def phone_confirm_by_otp(attriables = {})
        errors.add(:phone, :phone_already_confirmed) and return if phone_confirmed?
        errors.add(:phone, :otp_expired) and return if otp_expired?

        if attriables[:otp_check] == otp && (!self.class.generate_prefix && attriables[:otp_prefix] == otp_prefix)
          self.phone_confirmed_at = Time.now.utc
          saved = save(validate: true)
          after_phone_confirmation if saved
          saved
        else
          errors.add(:phone, :code_or_prefix_incorrect)
        end
        self
      end

      def phone_confirm!
        self.phone_confirmed_at = Time.now.utc
        save!
      end

      def phone_confirmed?
        !!phone_confirmed_at
      end

      def otp_expired?
        self.class.opt_available_time.present? && Time.now.utc > phone_confirmation_otp_send_at.utc + self.class.otp_available_time
      end

      def after_phone_confirmation; end

      def generate_confirm_otp
        self.otp, self.otp_prefix = DevisePhone::OTPGenerator.generate_otp(self.class.otp_length, self.class.generate_prefix)
        self.phone_confirmation_otp_send_at = Time.now.utc
      end

      def generate_confirm_otp!
        generate_confirm_otp && save(validate: false)
      end

      module ClassMethods
        ::Devise::Models.config(self, :otp_length, :generate_prefix, :otp_available_time)
        def phone_confirm_by_otp(attriables = {})
          confirmable = find_or_initialize_with_error_by(:phone, attriables[:phone])
          confirmable.phone_confirm_by_otp(attriables) if confirmable.present?
          confirmable
        end

        def send_phone_confirmation_otp(phone)
          confirmable = find_or_initialize_with_error_by(:phone, phone)
          return confirmable unless confirmable.persisted?

          confirmable.generate_confirm_otp!
          confirmable.send_texter
          confirmable
        end

        def otp_available_time
          10.minutes
        end
      end
    end
  end
end
