# frozen_string_literal: true

class OtpVerification < ActiveRecord::Base
  belongs_to :otp_verified, polymorphic: true
  after_initialize :generate_otp 
  attr_accessor :otp_check

  def verify(attriables)
    return errors.add(:otp, :otp_verified) if verified?
    return errors.add(:otp, :otp_expired) if expired?
    return errors.add(:otp, :otp_unverified) if otp_check != otp
    
    verified_at = Time.now.utc
  end

  def verify!(attriables)
    verify(attriables) && save!
  end

  def verified?
    verified_at.present? 
  end

  def expired?
    Devise.opt_available_time.present? && Time.now.utc > created_at.utc + Devise.otp_available_time
  end

  protected

  def generate_otp
    otp, otp_prefix = DevisePhone::OTPGenerator.generate_otp(Devise.otp_length, Devise.generate_prefix)
  end
end