require_relative 'active_record/otp_verification'

module Devise
  module Models
    module OtpVerifiable
      extend ActiveSupport::Concern

      included do
        has_many :otp_verifications, class_name: 'OTPVerification', as: :resource
      end

      def generate_otp
        otp_verification.create!
      end

      def verify_otp(attriable)
        otp_verification.last.verify!(attriable)
        self
      end
    end
  end
end
