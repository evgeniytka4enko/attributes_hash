require "spec_helper"

describe AttributesHash::ActiveRecordBaseExtensions do
  describe '.attribute_value' do
    let(:record) { AttributesHashSpecHelpers::create_record! }

    Record.class_available_attributes.each do |attribute|
      it "returns correct value for #{attribute}" do
        expect(record.attribute_value(attribute)).to eq(record.send(attribute))
      end
    end
  end

  describe '.default_attributes_root' do
    let(:record) { AttributesHashSpecHelpers::create_record! }

    subject { record.default_attributes_root }

    it 'returns correct root' do
      expect(subject).to eq('record')
    end
  end

  describe '.class_available_attributes' do
    subject { Record.class_available_attributes }

    let(:correct_class_available_attributes) { Record::send(:available_record_attributes) +
                                                Record::send(:available_method_attributes) +
                                                Record::send(:available_reference_attributes)}

    it 'returns correct attributes' do
      expect(subject).to match_array(correct_class_available_attributes)
    end
  end

  describe '.default_available_attributes' do
    subject { Record.default_available_attributes }

    it 'returns correct attributes' do
      expect(subject).to match_array(Record::send(:available_record_attributes))
    end
  end

  describe '.available_record_attributes' do
    subject { Record::send(:available_record_attributes) }

    it 'returns correct attributes' do
      expect(subject).to match_array([:id, :polymorphicable_id, :polymorphicable_type, :integer_column, :float_column, :boolean_column, :string_column, :datetime_column, :created_at, :updated_at])
    end
  end

  describe '.available_method_attributes' do
    subject { Record::send(:available_method_attributes) }

    it 'returns correct attributes' do
      expect(subject).to match_array([:integer_method, :string_method, :string_serializer_method, :has_many_record_ids, :has_and_belongs_to_many_record_ids])
    end
  end

  describe '.available_reference_attributes' do
    subject { Record::send(:available_reference_attributes) }

    it 'returns correct attributes' do
      expect(subject).to match_array([:polymorphicable, :has_one_record, :has_many_records, :has_and_belongs_to_many_records])
    end
  end

  describe '.attributes_preload_options' do
    before { Record.available_attributes only: Record.all_available_attributes }
    after { Record.available_attributes(nil) }

    context 'eager_load' do
      subject { Record::send(:attributes_preload_options, attributes, true) }

      context 'empty attributes' do
        let(:attributes) { [] }

        it 'returns correct attributes_preload_options' do
          expect(subject).to match_array([])
        end
      end

      context 'class available attributes' do
        let(:attributes) { Record.class_available_attributes }

        it 'returns correct attributes_preload_options' do
          expect(subject).to match_array([:has_one_record, :has_many_records, :has_and_belongs_to_many_records])
        end
      end

      context 'ids attributes' do
        let(:attributes) { [:has_many_record_ids, :has_and_belongs_to_many_record_ids] }

        it 'returns correct attributes_preload_options' do
          expect(subject).to match_array([:has_many_records, :has_and_belongs_to_many_records])
        end
      end

      context 'class available attributes with nested attributes' do
        let(:attributes) { Record.class_available_attributes + [{
                                                                    polymorphicable: [:integer_column],
                                                                    has_one_record: [:integer_column],
                                                                    has_many_records: [:integer_column],
                                                                    has_and_belongs_to_many_records: [:integer_column]
                                                                }] }

        it 'returns correct attributes_preload_options' do
          expect(subject).to match_array([:has_one_record, :has_many_records, :has_and_belongs_to_many_records])
        end
      end

      context 'class available attributes with nested nested attributes' do
        let(:attributes) { Record.class_available_attributes + [{
                                                                    polymorphicable: [:integer_column],
                                                                    has_one_record: [:integer_column],
                                                                    has_many_records: [:record],
                                                                    has_and_belongs_to_many_records: [:integer_column]
                                                                }] }

        it 'returns correct attributes_preload_options' do
          expect(subject).to match_array([:has_one_record, { has_many_records: [:record] }, :has_and_belongs_to_many_records])
        end
      end
    end

    context 'preload' do
      subject { Record::send(:attributes_preload_options, attributes, false) }

      context 'empty attributes' do
        let(:attributes) { [] }

        it 'returns correct attributes_preload_options' do
          expect(subject).to match_array([])
        end
      end

      context 'class available attributes' do
        let(:attributes) { Record.class_available_attributes }

        it 'returns correct attributes_preload_options' do
          expect(subject).to match_array([:polymorphicable])
        end
      end

      context 'class available attributes with nested attributes' do
        let(:attributes) { Record.class_available_attributes + [{
                                                                    polymorphicable: [:integer_column],
                                                                    has_one_record: [:integer_column],
                                                                    has_many_records: [:integer_column],
                                                                    has_and_belongs_to_many_records: [:integer_column]
                                                                }] }

        it 'returns correct attributes_preload_options' do
          expect(subject).to match_array([:polymorphicable])
        end
      end

      context 'class available attributes with nested nested attributes' do
        let(:attributes) { Record.class_available_attributes + [{
                                                                    polymorphicable: [:has_one_record],
                                                                    has_one_record: [:integer_column],
                                                                    has_many_records: [:record],
                                                                    has_and_belongs_to_many_records: [:integer_column]
                                                                }] }

        it 'returns correct attributes_preload_options' do
          expect(subject).to match_array([:polymorphicable])
        end
      end
    end
  end
end
