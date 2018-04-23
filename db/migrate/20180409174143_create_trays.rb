class CreateTrays < ActiveRecord::Migration[5.2]
  def change
    create_table :trays do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
  end
end
