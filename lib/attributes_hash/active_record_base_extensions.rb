module AttributesHash::ActiveRecordBaseExtensions
  extend ActiveSupport::Concern

  included do
    def attribute_value(attribute)
      send(attribute)
    end

    def default_attributes_root
      self.class.name.underscore
    end
  end

  class_methods do
    def class_available_attributes
      available_record_attributes + available_method_attributes + available_reference_attributes
    end

    def default_available_attributes
      available_record_attributes
    end

    def attributes_preload(attributes = [])
      eager_load(attributes_preload_options(attributes, true)).preload(attributes_preload_options(attributes, false))
    end

    def attributes_preload_options(attributes = [], eager_load = true)
      preload_options = []
      preload_option_keys = []

      attributes = process_attributes(attributes)

      attributes.each do |attribute|
        if attribute.is_a?(Hash) && available_reference_attributes.include?(attribute.keys.first)
          key = attribute.keys.first
          reflection = reflections[key.to_s]
          if reflection.polymorphic? ^ eager_load
            nested_preload_options = reflection.klass.attributes_preload_options(attribute[key], eager_load) if eager_load
            if nested_preload_options.present?
              preload_options << { key =>  nested_preload_options }
              if preload_option_keys.include?(key)
                preload_options.delete(key)
              else
                preload_option_keys << key
              end
            elsif preload_option_keys.exclude?(key)
              preload_options << key
              preload_option_keys << key
            end
          end
        else
          reflection_name = attribute.to_s
          reflection_name = reflection_name.gsub(/_ids$/, '').pluralize if reflection_name.include?('_ids')
          next if available_reference_attributes.exclude?(reflection_name.to_sym)
          if preload_option_keys.exclude?(reflection_name.to_sym) && reflections[reflection_name].polymorphic? ^ eager_load
            preload_options << reflection_name.to_sym
            preload_option_keys << reflection_name.to_sym
          end
        end
      end

      preload_options
    end

    private
    def available_record_attributes
      @available_record_attributes ||= attribute_names.map(&:to_sym)
    end

    def available_method_attributes
      if @available_method_attributes.nil?
        invalid_prefixes = ['after_', 'before_', 'validate_', 'autosave_', 'belongs_to']
        invalid_suffixes = ['=']
        names = instance_methods(false).map(&:to_s).reject do |method_name|
          has_invalid_prefix = invalid_prefixes.any? { |prefix| method_name.start_with?(prefix) }
          has_invalid_suffix = invalid_suffixes.any? { |suffix| method_name.end_with?(suffix) }
          has_invalid_prefix || has_invalid_suffix
        end
        reflections.each do |key, reflection|
          if reflection.is_a?(ActiveRecord::Reflection::HasManyReflection) || reflection.is_a?(ActiveRecord::Reflection::HasAndBelongsToManyReflection)
            name = "#{key.singularize}_ids"
            names << name unless names.include?(name)
          end
        end
        @available_method_attributes = names.map(&:to_sym)
      end
      @available_method_attributes
    end

    def available_reference_attributes
      @available_reference_attributes ||= reflections.keys.map(&:to_sym)
    end
  end
end
