ActiveRecord::Schema.define do
  self.verbose = false

  create_table :records, :force => true do |t|
    t.integer :polymorphicable_id
    t.string :polymorphicable_type
    t.integer :integer_column
    t.float :float_column
    t.boolean :boolean_column
    t.string :string_column
    t.datetime :datetime_column
    t.timestamps
  end

  create_table :has_one_records, :force => true do |t|
    t.integer :record_id
    t.integer :integer_column
    t.float :float_column
    t.boolean :boolean_column
    t.string :string_column
    t.datetime :datetime_column
    t.timestamps
  end

  create_table :has_many_records, :force => true do |t|
    t.integer :record_id
    t.integer :integer_column
    t.float :float_column
    t.boolean :boolean_column
    t.string :string_column
    t.datetime :datetime_column
    t.timestamps
  end

  create_table :has_and_belongs_to_many_records, :force => true do |t|
    t.integer :integer_column
    t.float :float_column
    t.boolean :boolean_column
    t.string :string_column
    t.datetime :datetime_column
    t.timestamps
  end

  create_join_table :records, :has_and_belongs_to_many_records

  add_foreign_key :has_one_records, :records
  add_foreign_key :has_many_records, :records
end