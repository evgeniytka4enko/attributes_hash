class Record < ActiveRecord::Base
  belongs_to :polymorphicable, polymorphic: true
  has_one :has_one_record
  has_many :has_many_records
  has_and_belongs_to_many :has_and_belongs_to_many_records

  attribute_serializer :integer_serializer, -> { integer_column }
  attribute_serializer :string_serializer, :string_serializer_method

  def integer_method
    integer_column
  end

  def string_method
    string_column
  end

  def string_serializer_method
    string_column
  end
end

class HasOneRecord < ActiveRecord::Base
  belongs_to :record

  available_attributes except: [:datetime_column]
end

class HasManyRecord < ActiveRecord::Base
  belongs_to :record

  available_attributes only: [:id, :record, :integer_column, :float_column, :boolean_column, :string_column, :datetime_column, :created_at, :updated_at, :not_existing_attribute]
end

class HasAndBelongsToManyRecord < ActiveRecord::Base
  has_and_belongs_to_many :records
end