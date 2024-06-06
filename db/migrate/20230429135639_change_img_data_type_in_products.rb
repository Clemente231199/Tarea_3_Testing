# frozen_string_literal: true

class ChangeImgDataTypeInProducts < ActiveRecord::Migration[6.0]
  def change
    change_column :products, :img, :string
  end
end
