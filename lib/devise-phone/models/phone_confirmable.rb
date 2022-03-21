# frozen_string_literal: true

module Devise
  module Models
    # Phone Confirmable is responsible to verify if an account is already confirmed to
    # sign in, and to send sms with one time password (OTP).
    # OTP are sent to the user phone after creating a
    # record and when manually requested by a new otp request.
    #
    # Phone Confirmable tracks the following columns:
    #
    # * phone                       - User's phone number
    # * otp                         - A random password
    # * otp_prefix                  - A random letters
    # * phone_confirmed_at          - A timestamp when the user input the correct OTP
    # * phoen_confirmation_sent_at  - A timestamp when the otp was generated (not sent)
    #
    # == Options
    #
    # Phone Confirmable adds the following options to +devise+:
    #
    #   * +otp_length+: default is 6 random numbers, you can change otp length by this option
    #   * +generate_prefix+: should generate OTP prefix, prefix is a random letters for OTP.
    #     User can make sure that prefix on SMS is same as OTP from label that avoid confusion
    #     with previously OTP
    #   * +:otp_available_time+: time available for OTP, within 10 minutes after generate by default.
    #
    # == Examples
    #
    #   User.find(1).phone_confirm                            # returns true unless it's already confirmed
    #   User.find(1).phone_confirmed?                         # true/false
    #   User.find(1).send_and_generate_phone_confirmation_otp # manually send and generate phone confirm OTP
    #
    module PhoneConfirmable
      extend ActiveSupport::Concern

      included do
        attr_accessor :otp_check

        after_commit :send_and_generate_phone_confirmation_otp, on: %i[create update], if: -> { phone.present? }
      end

      def self.required_fields(_klass)
        %i[phone phone_confirmed_at otp_prefix otp phone_confirmation_otp_send_at]
      end

      def send_and_generate_phone_confirmation_otp
        generate_confirm_otp!
        send_otp_sms
      end

      def send_otp_sms; end

      def phone_confirm_by_otp(attriables)
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
        self.otp, self.otp_prefix = DevisePhone::OTPGenerator.generate_otp(self.class.otp_length,
                                                                           self.class.generate_prefix)
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

        def send_and_generate_phone_confirmation_otp(phone)
          confirmable = find_or_initialize_with_error_by(:phone, phone)
          return confirmable unless confirmable.persisted?

          confirmable.generate_confirm_otp!
          confirmable.send_otp_sms
          confirmable
        end

        def otp_available_time
          10.minutes
        end
      end
    end
  end
end
