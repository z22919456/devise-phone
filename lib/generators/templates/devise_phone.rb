# frozen_string_literal: true

Devise.setup do |config|
  # Configure OTP length.
  # Default is 6
  config.otp_length = 6

  # Configure should generate prefix.
  # How many letters need to ber generated, 0 or nil if prefix is not required. Default is 3
  config.generate_prefix = 3

  # Configure available time
  # How many time available after generate. default is 10 minutes
  config.otp_available_time = 10
end
