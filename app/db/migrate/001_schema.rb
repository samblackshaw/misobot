class Schema < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :name, unique: true

      # Stream tokens
      t.integer :tokens,  default: 0
    end
  end
end
