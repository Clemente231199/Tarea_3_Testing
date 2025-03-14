# frozen_string_literal: true

class AddHorariosToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :horarios, :string
  end
end
