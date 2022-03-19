# frozen_string_literal: true

class DeviseCreateOTPVerifications < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :otp_verifications do |t|
      t.belongs_to :resource, polymorphic: true
      t.string     :phone
      t.string     :otp_prefix
      t.string     :otp
      t.datetime   :verified_at
      t.timestamps
    end
  end
end