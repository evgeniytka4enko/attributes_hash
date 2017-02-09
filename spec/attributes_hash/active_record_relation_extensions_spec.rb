require "spec_helper"

describe AttributesHash::ActiveRecordRelationExtensions do
  describe '.default_attributes_root' do
    let(:record) { AttributesHashSpecHelpers::create_record! }
    let(:has_many_record) { AttributesHashSpecHelpers::create_has_many_record!(record_id: record.id) }

    subject { record.has_many_records.default_attributes_root }

    it 'returns correct root' do
      expect(subject).to eq('has_many_record')
    end
  end
end
