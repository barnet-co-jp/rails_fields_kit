# frozen_string_literal: true

require "delegate"

module RailsFieldsKit
  module FormBuilderTomSelectInitialState
    private

    SELECT_BACKED_KINDS = %i[
      select
      multi_select
      enum_select
      combobox
      tags
    ].freeze

    SINGLE_SELECT_KINDS = %i[
      select
      grouped_select
      enum_select
      combobox
    ].freeze

    def rfk_tom_select_field(method, field_kind, collection: nil, **options)
      options = options.dup
      collection = rfk_prepare_initial_state_collection(field_kind, collection, options)
      rfk_apply_native_select_placeholder!(field_kind, options)

      if field_kind == :lookup && options.key?(:selected)
        rfk_with_lookup_selected_object(method, options) do
          super(method, field_kind, collection: collection, **options)
        end
      else
        super(method, field_kind, collection: collection, **options)
      end
    end

    def rfk_prepare_initial_state_collection(field_kind, collection, options)
      return collection unless SELECT_BACKED_KINDS.include?(field_kind)

      selected_value_method = options[:value_method] || :id
      collection_value_method = options[:collection_value_method] || selected_value_method

      if collection && options.key?(:selected) && rfk_static_collection_options?(options)
        allowed_values = rfk_collection_values(collection, collection_value_method)
        options[:selected] = rfk_filter_static_scalar_selected(options[:selected], allowed_values, selected_value_method)
      end

      return collection unless rfk_option_present?(options[:selected_url]) && options.key?(:selected)

      pending_values = rfk_pending_scalar_selected_values(options[:selected], selected_value_method)
      return collection if pending_values.empty?

      existing_values = rfk_collection_values(collection, collection_value_method).map(&:to_s)
      missing_values = pending_values.reject { |value| existing_values.include?(value.to_s) }
      return collection if missing_values.empty?

      rfk_mark_pending_selected_options!(options, missing_values)
      rfk_collection_with_pending_selected(collection, missing_values)
    end

    def rfk_static_collection_options?(options)
      !rfk_option_present?(options[:url]) && !rfk_option_present?(options[:selected_url])
    end

    def rfk_collection_values(collection, value_method)
      case collection
      when nil
        []
      when Hash
        collection.values
      else
        collection.to_a.map do |item|
          if item.is_a?(Array) && item.size == 2
            item[1]
          else
            rfk_read_selected_value(item, value_method)
          end
        end
      end
    end

    def rfk_filter_static_scalar_selected(selected, allowed_values, value_method)
      allowed = allowed_values.map(&:to_s)

      if selected.is_a?(Array)
        selected.select do |entry|
          rfk_rich_selected_entry?(entry, value_method) || allowed.include?(rfk_read_selected_value(entry, value_method).to_s)
        end
      elsif rfk_rich_selected_entry?(selected, value_method)
        selected
      elsif allowed.include?(rfk_read_selected_value(selected, value_method).to_s)
        selected
      end
    end

    def rfk_pending_scalar_selected_values(selected, value_method)
      case selected
      when nil, Hash
        []
      when Array
        selected.flat_map do |entry|
          if entry.is_a?(Array) && entry.size == 2
            []
          else
            rfk_pending_scalar_selected_values(entry, value_method)
          end
        end
      else
        return [] if rfk_rich_selected_entry?(selected, value_method)

        value = rfk_read_selected_value(selected, value_method)
        rfk_option_present?(value) ? [value] : []
      end
    end

    def rfk_rich_selected_entry?(entry, value_method)
      return true if entry.is_a?(Hash)
      return true if entry.is_a?(Array) && entry.size == 2
      return false if entry.nil? || entry.is_a?(String) || entry.is_a?(Symbol) || entry.is_a?(Numeric) || entry == true || entry == false

      entry.respond_to?(value_method)
    end

    def rfk_collection_with_pending_selected(collection, pending_values)
      entries = case collection
      when nil
        []
      when Hash
        collection.map { |label, value| [label, value] }
      else
        collection.to_a.dup
      end

      pending_values.reverse_each { |value| entries.unshift([value.to_s, value]) }
      entries
    end

    def rfk_mark_pending_selected_options!(options, pending_values)
      existing_option_html = options[:option_html]
      pending = pending_values.map(&:to_s)

      options[:option_html] = lambda do |value|
        html = rfk_initial_state_option_html(existing_option_html, value)
        next html unless pending.include?(value.to_s)

        html = html.dup
        data = (html[:data] || html["data"] || {}).dup
        html.delete("data")
        data[:rfk_selected_label_pending] = true
        html[:data] = data
        html
      end
    end

    def rfk_initial_state_option_html(option_html, value)
      case option_html
      when Proc
        option_html.call(value) || {}
      when Hash
        option_html[value] || option_html[value.to_s] || {}
      else
        {}
      end
    end

    def rfk_apply_native_select_placeholder!(field_kind, options)
      return unless SINGLE_SELECT_KINDS.include?(field_kind)
      return unless options.key?(:placeholder)
      return unless rfk_option_present?(options[:placeholder])
      return if options.key?(:include_blank) || options.key?(:prompt)

      options[:include_blank] = options[:placeholder]
    end

    def rfk_with_lookup_selected_object(method, options)
      lookup_id_field = options[:lookup_id_field]
      return yield unless lookup_id_field

      selected = options[:selected]
      value_method = options[:value_method] || :id
      label_method = options[:label_method] || :to_s
      selected_choice = rfk_normalize_selected(selected, value_method: value_method, label_method: label_method).first
      return yield unless selected_choice

      selected_id = selected_choice[1]
      current_id = object.public_send(lookup_id_field) if object.respond_to?(lookup_id_field)
      explicit_label = rfk_lookup_selected_label_explicit?(selected, value_method, label_method)
      return yield if !explicit_label && current_id.to_s == selected_id.to_s

      selected_text = if explicit_label
        selected_choice[0]
      elsif current_id.to_s == selected_id.to_s && object.respond_to?(method)
        object.public_send(method)
      end

      original_object = @object
      proxy = SimpleDelegator.new(original_object)
      original_class = original_object.class
      proxy.define_singleton_method(:class) { original_class }
      proxy.define_singleton_method(method.to_sym) { selected_text }
      proxy.define_singleton_method(lookup_id_field.to_sym) { selected_id }
      @object = proxy
      yield
    ensure
      @object = original_object if defined?(original_object)
    end

    def rfk_lookup_selected_label_explicit?(selected, value_method, label_method)
      if selected.is_a?(Hash)
        return %i[text label name].any? do |key|
          (selected.key?(key) && !selected[key].nil?) || (selected.key?(key.to_s) && !selected[key.to_s].nil?)
        end
      end

      rfk_rich_selected_entry?(selected, value_method) && selected.respond_to?(label_method)
    end

    def rfk_option_present?(value)
      return false if value.nil?
      return false if value.respond_to?(:empty?) && value.empty?

      true
    end
  end

  FormBuilder.prepend(FormBuilderTomSelectInitialState)
end
