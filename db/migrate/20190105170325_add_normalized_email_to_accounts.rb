# frozen_string_literal: true

class AddNormalizedEmailToAccounts < ActiveRecord::Migration[5.2]
  def change
    change_table :accounts do |t|
      t.string :normalized_email
      t.string :hashed_email
    end
  end
end
