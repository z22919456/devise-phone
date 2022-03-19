module Devise
  module Models
    # Phone Confirmable is responsible to verify if an account is already confirmed to
    # sign in, and to send sms with one time password (OTP).
    # OTP are sent to the user phone after creating a
    # record and when manually requested by a new otp request.
    #
    # Phone Confirmable tracks the following columns:
    #
    # * phone                - User's phone number
    # * otp                  - A random password
    # * otp_prefix           -
    # * confirmation_token   - A unique random token
    # * confirmed_at         - A timestamp when the user clicked the confirmation link
    # * confirmation_sent_at - A timestamp when the confirmation_token was generated (not sent)
    # * unconfirmed_email    - An email address copied from the email attr. After confirmation
    #                          this value is copied to the email attr then cleared
    #
    # == Options
    #
    # Confirmable adds the following options to +devise+:
    #
    #   * +allow_unconfirmed_access_for+: the time you want to allow the user to access their account
    #     before confirming it. After this period, the user access is denied. You can
    #     use this to let your user access some features of your application without
    #     confirming the account, but blocking it after a certain period (ie 7 days).
    #     By default allow_unconfirmed_access_for is zero, it means users always have to confirm to sign in.
    #   * +reconfirmable+: requires any email changes to be confirmed (exactly the same way as
    #     initial account confirmation) to be applied. Requires additional unconfirmed_email
    #     db field to be set up (t.reconfirmable in migrations). Until confirmed, new email is
    #     stored in unconfirmed email column, and copied to email column on successful
    #     confirmation. Also, when used in conjunction with `send_email_changed_notification`,
    #     the notification is sent to the original email when the change is requested,
    #     not when the unconfirmed email is confirmed.
    #   * +confirm_within+: the time before a sent confirmation token becomes invalid.
    #     You can use this to force the user to confirm within a set period of time.
    #     Confirmable will not generate a new token if a repeat confirmation is requested
    #     during this time frame, unless the user's email changed too.
    #
    # == Examples
    #
    #   User.find(1).confirm       # returns true unless it's already confirmed
    #   User.find(1).confirmed?    # true/false
    #   User.find(1).send_confirmation_instructions # manually send instructions
    #
    module PhoneConfirmable
      extend ActiveSupport::Concern

      included do
        attr_accessor :otp_check

        after_commit :send_phone_confirmation_otp, on: %i[create update], if: phone.present?
      end

      def self.required_fields(_klass)
        %i[phone phone_confirmed_at otp_prefix otp phone_confirmation_otp_send_at]
      end

      def send_phone_confirmation_otp(params)
        generate_confirm_otp!(params)
        send_otp_sms
      end

      def send_otp_sms; end

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

        def send_phone_confirmation_otp(phone)
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
