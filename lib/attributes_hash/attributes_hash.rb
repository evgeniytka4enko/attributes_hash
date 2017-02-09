module AttributesHash::AttributesHash
  extend ActiveSupport::Concern

  included do
    def to_attributes_hash(attributes = [], options = { root: true })
      if respond_to?(:each)
        attributes_hash = []

        each do |object|
          attributes_hash << object.to_attributes_hash(attributes, options.merge(root: false))
        end
      else
        attributes_hash = {}

        attributes = self.class.process_attributes(attributes)

        attributes.each do |attribute|
          if attribute.is_a?(Hash)
            attribute_name = attribute.keys.first
            nested_attributes = attribute[attribute_name]
          else
            attribute_name = attribute
            nested_attributes = []
          end

          attribute_serializer = self.class.current_attribute_serializers[attribute_name]
          if attribute_serializer.present?
            value = instance_exec(&attribute_serializer)
          else
            value = attribute_value(attribute_name)
            value = value.to_attributes_hash(nested_attributes, root: false) if value.respond_to?(:to_attributes_hash)
          end
          attributes_hash[attribute_name] = value
        end
      end

      root = options[:root]
      if root.present?
        if root == true
          root = respond_to?(:default_attributes_root) ? default_attributes_root : self.class.name.underscore
          root = root.pluralize if respond_to?(:each)
        end
        attributes_hash = { root.to_sym => attributes_hash }
      end
      attributes_hash
    end
  end

  class_methods do
    def available_attributes(options = {})
      @available_attributes_options = options&.symbolize_keys
      @current_available_attributes = nil if options.nil?
    end

    def current_available_attributes
      if @available_attributes_options.present?
        only_attributes = @available_attributes_options[:only]
        except_attributes = @available_attributes_options[:except]
        if except_attributes.present?
          @current_available_attributes = all_available_attributes - except_attributes.map(&:to_sym)
        elsif only_attributes.present?
          @current_available_attributes = only_attributes.map(&:to_sym) & all_available_attributes
        end

        @available_attributes_options = nil
      end

      if @current_available_attributes.present?
        @current_available_attributes
      else
        all_available_attributes
      end
    end

    def all_available_attributes
      class_available_attributes + current_attribute_serializers.keys
    end

    def attribute_serializer(name, body)
      if body.respond_to?(:call)
        block = body
      elsif body.is_a?(String) || body.is_a?(Symbol)
        block = -> { send(body) }
      end

      @attributes_serializers = {} if @attributes_serializers.nil?
      @attributes_serializers[name.to_sym] = block
    end

    def current_attribute_serializers
      @attributes_serializers || {}
    end

    def process_attributes(attributes = [])
      processed_attributes = []
      processed_attribute_names = []
      attributes&.each do |attribute|
        if attribute.is_a?(Hash)
          attribute.symbolize_keys.each do |key, value|
            next if current_available_attributes.exclude?(key)
            if value&.any?
              processed_attributes << { key => value }
              if processed_attribute_names.include?(key)
                processed_attributes.delete(key)
              else
                processed_attribute_names << key
              end
            elsif processed_attribute_names.exclude?(key)
              processed_attributes << key
              processed_attribute_names << key
            end
          end
        else
          attribute = attribute.to_sym
          if processed_attribute_names.exclude?(attribute) && current_available_attributes.include?(attribute)
            processed_attributes << attribute
            processed_attribute_names << attribute
          end
        end
      end

      processed_attributes.any? ? processed_attributes : default_available_attributes
    end
  end
end
