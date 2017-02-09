require 'faker'

module AttributesHashSpecHelpers
  def self.create_record!(attributes = {})
    Record.create!(record_attributes.merge(attributes))
  end

  def self.create_has_one_record!(attributes = {})
    HasOneRecord.create!(record_attributes.merge(attributes))
  end

  def self.create_has_many_record!(attributes = {})
    HasManyRecord.create!(record_attributes.merge(attributes))
  end

  def self.create_has_and_belongs_to_many_record!(attributes = {})
    HasAndBelongsToManyRecord.create!(record_attributes.merge(attributes))
  end

  def self.record_attributes
    {
        integer_column: Faker::Number.between.to_i,
        float_column: Faker::Number.between,
        boolean_column: Faker::Boolean.boolean,
        string_column: Faker::Lorem.word,
        datetime_column: Faker::Date.birthday
    }
  end
end