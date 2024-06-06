# frozen_string_literal: true

class AddDefaultRoleToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :role, :string, default: 'normal'
  end
end
