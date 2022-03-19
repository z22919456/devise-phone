# frozen_string_literal: true

require 'active_record'
require 'devise-phone/version'
require 'devise-phone/routes'
require 'devise-phone/rails'
require 'devise-phone/models/phone_confirmable'
require 'devise-phone/models/otp_verifiable'
require 'devise-phone/models/active_record/otp_verification'
require 'devise-phone/otp_generator'
require 'devise'

module Devise
  mattr_accessor :otp_length
  @@otp_length = 6

  mattr_accessor :generate_prefix
  @@generate_prefix = true

  mattr_accessor :otp_available_time
  @@otp_available_time = 10.minutes

  mattr_accessor :should_verify_otp_when_change_password
  @@should_verify_otp_when_change_password = true
end

Devise.add_module :phone_confirmable, controller: :phone_confirmations, route: { phone_confirmation: [nil, :new] }
Devise.add_module :otp_verifiable
