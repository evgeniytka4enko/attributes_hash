require "spec_helper"

describe AttributesHash::AttributesHash do
  describe '.to_attributes_hash' do
    let(:has_one_record) { AttributesHashSpecHelpers::create_has_one_record! }
    let(:has_many_record) { AttributesHashSpecHelpers::create_has_many_record! }
    let(:has_many_record2) { AttributesHashSpecHelpers::create_has_many_record! }
    let(:has_and_belongs_to_many_record) { AttributesHashSpecHelpers::create_has_and_belongs_to_many_record! }
    let(:has_and_belongs_to_many_record2) { AttributesHashSpecHelpers::create_has_and_belongs_to_many_record! }
    let(:polymorphicable) { AttributesHashSpecHelpers::create_record! }
    let(:record) { AttributesHashSpecHelpers::create_record!(polymorphicable: polymorphicable, has_one_record: has_one_record, has_many_records: [has_many_record, has_many_record2], has_and_belongs_to_many_records: [has_and_belongs_to_many_record, has_and_belongs_to_many_record2]) }

    subject { record.to_attributes_hash(attributes, options) }

    context 'without specific available attributes' do
      context 'empty attributes' do
        let(:attributes) { [] }
        let(:options) { { root: false } }

        it 'returns correct attributes hash' do
          expect(subject.keys).to match_array(Record.default_available_attributes)
          subject.each do |key, value|
            expect(record.attribute_value(key)).to eq(value)
          end
        end
      end

      context 'all available attributes' do
        let(:attributes) { Record.all_available_attributes }
        let(:options) { { root: false } }

        it 'returns correct attributes hash' do
          expect(subject.keys).to match_array(Record.all_available_attributes)

          object_attributes = [:has_one_record, :has_many_records, :has_and_belongs_to_many_records]
          simple_attributes = Record.all_available_attributes - object_attributes
          subject.slice(simple_attributes).each do |key, value|
            expect(record.attribute_value(key)).to eq(value)
          end

          subject.slice(object_attributes).each do |key, value|
            expect(record.attribute_value(key).to_attributes_hash).to eq(value)
          end
        end
      end

      context 'specific attributes' do
        let(:attributes) { [ :id, :integer_column, :not_existing_attribute ] }
        let(:options) { { root: false } }

        it 'returns correct attributes hash' do
          expect(subject.keys).to match_array([ :id, :integer_column ])
          subject.each do |key, value|
            expect(record.attribute_value(key)).to eq(value)
          end
        end
      end

      context 'nested attributes' do
        let(:attributes) { [{ polymorphicable: [:integer_column, :not_existing_attribute],
                              has_one_record: [:integer_column, :not_existing_attribute],
                              has_many_records: [:integer_column, :not_existing_attribute],
                              has_and_belongs_to_many_records: [:integer_column, :not_existing_attribute]}] }
        let(:options) { { root: false } }

        it 'returns correct attributes hash' do
          expect(subject.keys).to match_array([ :polymorphicable, :has_one_record, :has_many_records, :has_and_belongs_to_many_records ])
          expect(record.polymorphicable.to_attributes_hash(attributes.first[:polymorphicable], root: false)).to eq(subject[:polymorphicable])
          expect(record.has_one_record.to_attributes_hash(attributes.first[:has_one_record], root: false)).to eq(subject[:has_one_record])
          expect(record.has_many_records.to_attributes_hash(attributes.first[:has_many_records], root: false)).to eq(subject[:has_many_records])
          expect(record.has_and_belongs_to_many_records.to_attributes_hash(attributes.first[:has_and_belongs_to_many_records], root: false)).to eq(subject[:has_and_belongs_to_many_records])
        end
      end
    end

    context 'with specific available attributes' do
      before { Record.available_attributes only: Record.all_available_attributes }
      after { Record.available_attributes(nil) }

      context 'empty attributes' do
        let(:attributes) { [] }
        let(:options) { { root: false } }

        it 'returns correct attributes hash' do
          expect(subject.keys).to match_array(Record.default_available_attributes)
          subject.each do |key, value|
            expect(record.attribute_value(key)).to eq(value)
          end
        end
      end

      context 'all available attributes' do
        let(:attributes) { Record.all_available_attributes }
        let(:options) { { root: false } }

        it 'returns correct attributes hash' do
          expect(subject.keys).to match_array(Record.current_available_attributes)

          object_attributes = [:has_one_record, :has_many_records, :has_and_belongs_to_many_records]
          simple_attributes = Record.all_available_attributes - object_attributes
          subject.slice(simple_attributes).each do |key, value|
            expect(record.attribute_value(key)).to eq(value)
          end

          subject.slice(object_attributes).each do |key, value|
            expect(record.attribute_value(key).to_attributes_hash).to eq(value)
          end
        end
      end

      context 'specific attributes' do
        let(:attributes) { [ :id, :integer_column, :has_many_records, :has_and_belongs_to_many_record_ids, :not_existing_attribute ] }
        let(:options) { { root: false } }

        it 'returns correct attributes hash' do
          expect(subject.keys).to match_array([ :id, :integer_column, :has_many_records, :has_and_belongs_to_many_record_ids ])

          object_attributes = [:has_one_record, :has_many_records, :has_and_belongs_to_many_records]
          simple_attributes = Record.all_available_attributes - object_attributes
          subject.slice(simple_attributes).each do |key, value|
            expect(record.attribute_value(key)).to eq(value)
          end

          subject.slice(object_attributes).each do |key, value|
            expect(record.attribute_value(key).to_attributes_hash).to eq(value)
          end
        end
      end
    end
  end

  describe '.available_attributes and .current_available_attributes' do
    context 'without available_attributes' do
      subject { Record.current_available_attributes }

      it 'returns correct current_available_attributes' do
        expect(subject).to match_array(Record.all_available_attributes)
      end
    end

    context 'with only available_attributes' do
      before { Record.available_attributes only: [ :integer_column, :created_at, :not_existing_attribute ] }
      after { Record.available_attributes(nil) }

      subject { Record.current_available_attributes }

      it 'returns correct current_available_attributes' do
        expect(subject).to match_array([ :integer_column, :created_at ])
      end
    end

    context 'with except available_attributes' do
      before { Record.available_attributes except: [ :integer_column, :created_at, :not_existing_attribute ] }
      after { Record.available_attributes(nil) }

      subject { Record.current_available_attributes }

      it 'returns correct current_available_attributes' do
        expect(subject).to match_array(Record.all_available_attributes - [ :integer_column, :created_at ])
      end
    end
  end

  describe '.all_available_attributes' do
    subject { Record.all_available_attributes }

    it 'returns correct all_available_attributes' do
      expect(subject).to match_array(Record.class_available_attributes + Record.current_attribute_serializers.keys)
    end
  end

  describe '.attribute_serializer and .current_attribute_serializers' do
    let!(:name) { Faker::Lorem.word }

    context 'block' do
      before { Record.attribute_serializer(name, -> {}) }

      subject { Record.current_attribute_serializers }

      it 'returns correct attribute_serializers hash' do
        expect(subject[name.to_sym].class).to eq(Proc)
      end
    end

    context 'method name' do
      before do
        class Record
          def test_method
            Faker::Lorem.word
          end
        end
      end

      before { Record.attribute_serializer(name, :test_method) }

      subject { Record.current_attribute_serializers }

      it 'returns correct attribute_serializers hash' do
        expect(subject[name.to_sym].class).to eq(Proc)
      end
    end
  end

  describe '.process_attributes' do
    subject { Record.process_attributes(attributes) }

    context 'empty attributes' do
      let(:attributes) { [] }

      it 'returns current_available_attributes' do
        expect(subject).to match_array(Record.default_available_attributes)
      end
    end

    context 'filled attributes' do
      before { Record.available_attributes only: Record.all_available_attributes }
      after { Record.available_attributes(nil) }

      let(:attributes) { [
          'integer_column',
          :float_column,
          :has_many_record_ids,
          :has_and_belongs_to_many_record_ids,
          :not_existing_attribute,
          :has_one_record,
          {
              'has_one_record' => [
                  :string_column,
                  :datetime_column
              ],
              has_many_records: [
                  :string_column,
                  :datetime_column
              ],
              has_and_belongs_to_many_records: [
                  :string_column,
                  :datetime_column
              ],
              'not_existing_relation' => []
          },
          :has_many_records
      ] }

      let(:processed_attributes) { [
          :integer_column,
          :float_column,
          :has_many_record_ids,
          :has_and_belongs_to_many_record_ids,
          {
              has_one_record: [
                  :string_column,
                  :datetime_column
              ]
          },
          {
              has_many_records: [
                  :string_column,
                  :datetime_column
              ]
          },
          {
              has_and_belongs_to_many_records: [
                  :string_column,
                  :datetime_column
              ]
          }
      ] }

      it 'returns processed attributes' do
        expect(subject).to eq(processed_attributes)
      end
    end
  end
end
