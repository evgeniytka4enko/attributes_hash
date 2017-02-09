module AttributesHash::ActiveRecordRelationExtensions
  extend ActiveSupport::Concern

  included do
    def default_attributes_root
      klass.name.underscore
    end
  end

  class_methods do

  end
end
