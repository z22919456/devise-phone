# frozen_string_literal: true

class OTPVerification < ActiveRecord::Base
  belongs_to :resource, polymorphic: true
  before_save :generate_otp
  attr_accessor :otp_check

  def verify(_attriables)
    return errors.add(:otp, :otp_verifiable) if verified?
    return errors.add(:otp, :otp_expired) if expired?
    return errors.add(:otp, :otp_unverifiable) if otp_check != otp

    verified_at = Time.now.utc
    self
  end

  def verify!(attriables = {})
    verify(attriables) && save!
  end

  def verified?
    verified_at.present?
  end

  def expired?
    Devise.otp_available_time.present? && Time.now.utc > created_at.utc + Devise.otp_available_time
  end

  protected

  def generate_otp
    if otp.nil?
      self.otp, self.otp_prefix = DevisePhone::OTPGenerator.generate_otp(Devise.otp_length, Devise.generate_prefix)
      save!
    end
    true
  end
end
