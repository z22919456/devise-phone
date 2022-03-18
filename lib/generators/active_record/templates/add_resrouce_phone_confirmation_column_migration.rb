# frozen_string_literal: true

class DeviseAdd<%= table_name.camelize %>PhoneConfirmations < ActiveRecord::Migration<%= migration_version %>
  def up
    change_table :<%= table_name %> do |t|
      t.string     :phone
      t.string     :otp_prefix
      t.string     :otp
      t.datetime   :phone_confirmed_at
      t.datetime   :phone_confirmation_otp_send_at
    end
    add_index :<%= table_name %>, :phone, unique: true
  end

  def down
    change_table :<%= table_name %> do |t|
      t.remove :phone, :otp_prefix, :otp, :phone_confirmed_at, :phone_confirmation_otp_send_at
    end
  end
end