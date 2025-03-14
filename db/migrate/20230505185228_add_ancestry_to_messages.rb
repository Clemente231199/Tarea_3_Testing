# frozen_string_literal: true

class AddAncestryToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :ancestry, :string
  end
end
