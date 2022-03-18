# frozen_string_literal: true

module DevisePhone
  # Generate one time password with given length.
  module OTPGenerator
    def self.generate_otp(length = 6, generate_prefix = true)
      max_code = ''.rjust(length, '9').to_i
      code = Random.rand(0..max_code).to_s.rjust(length, '0')
      if generate_prefix
        prefix = (0...3).map { rand(65..90).chr }.join
        return [code, prefix]
      end

      code
    end
  end
end
