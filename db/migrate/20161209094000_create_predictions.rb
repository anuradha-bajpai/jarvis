class CreatePredictions < ActiveRecord::Migration[5.0]
  def change
    create_table :predictions do |t|
      t.decimal :height
      t.decimal :weight
      t.integer :is_dog_person
      t.integer :prediction
      t.decimal :metric_1

      t.timestamps
    end
  end
end
