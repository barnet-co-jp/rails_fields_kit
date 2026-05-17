# frozen_string_literal: true

require "json"

module RailsFieldsKit
  module FormBuilder
    def rfk_text_field(method, **options)
      rfk_native_field(method, :text_field, **options)
    end

    def rfk_text_area(method, **options)
      rfk_native_field(method, :text_area, **options)
    end

    def rfk_number_field(method, **options)
      rfk_native_field(method, :number_field, **options)
    end

    def rfk_select(method, collection: nil, **options)
      rfk_tom_select_field(method, :select, collection: collection, **options)
    end

    def rfk_combobox(method, collection: nil, **options)
      rfk_tom_select_field(method, :combobox, collection: collection, **options)
    end

    def rfk_tags(method, collection: nil, **options)
      options[:multiple] = true unless options.key?(:multiple)
      options[:plugins] = Array(options[:plugins]) | ["remove_button"] unless options.key?(:plugins)
      rfk_tom_select_field(method, :tags, collection: collection, **options)
    end

    def rfk_autocomplete(method, **options)
      options[:free_text] = true unless options.key?(:free_text)
      rfk_tom_select_field(method, :autocomplete, **options)
    end

    private

    def rfk_native_field(method, helper_name, **options)
      wrapper_options = rfk_extract_wrapper_options(options)
      html_options = options.delete(:html) || {}
      field_options = options.merge(html_options)
      field_html = public_send(helper_name, method, field_options)

      rfk_wrap_field(method, field_html, wrapper_options)
    end

    def rfk_tom_select_field(method, field_kind, collection: nil, **options)
      config = RailsFieldsKit.configuration
      wrapper_options = rfk_extract_wrapper_options(options)
      html_options = options.delete(:html) || {}
      data = html_options[:data] ||= {}
      data[:controller] = [data[:controller], config.controller_name].compact.join(" ")
      data[:rails_fields_kit__tom_select_kind_value] = field_kind

      selected = options.delete(:selected)
      value_method = options.delete(:value_method) || :id
      label_method = options.delete(:label_method) || :to_s
      selected_choices = rfk_normalize_selected(selected, value_method: value_method, label_method: label_method)

      rfk_assign_data_value(data, :url, options.delete(:url))
      rfk_assign_data_value(data, :create_url, options.delete(:create_url))
      rfk_assign_data_value(data, :create, options.delete(:create))
      rfk_assign_data_value(data, :free_text, options.delete(:free_text))
      rfk_assign_data_value(data, :placeholder, options[:placeholder])
      rfk_assign_data_value(data, :query_param, options.delete(:query_param) || config.default_query_param)
      rfk_assign_data_value(data, :create_param, options.delete(:create_param) || config.default_create_param)
      rfk_assign_data_value(data, :value_field, options.delete(:value_field) || config.default_value_field)
      rfk_assign_data_value(data, :label_field, options.delete(:label_field) || config.default_label_field)
      rfk_assign_data_value(data, :search_field, options.delete(:search_field) || config.default_search_field)
      rfk_assign_data_value(data, :min_length, options.delete(:min_length) || config.default_min_length)
      rfk_assign_data_value(data, :plugins, options.delete(:plugins) || config.default_plugins)

      html_options[:multiple] = options.delete(:multiple) if options.key?(:multiple)
      html_options[:placeholder] = options.delete(:placeholder) if options.key?(:placeholder)

      field_html = if field_kind == :autocomplete || html_options[:multiple] == false && options[:as] == :text
        text_field(method, options.merge(html_options))
      else
        choices = rfk_choices_with_selected(collection, selected_choices: selected_choices)
        options[:selected] ||= rfk_selected_values(selected_choices) if selected_choices.any?
        select(method, choices, options, html_options)
      end

      rfk_wrap_field(method, field_html, wrapper_options)
    end

    def rfk_extract_wrapper_options(options)
      {
        label: options.delete(:label),
        hint: options.delete(:hint),
        wrapper: options.key?(:wrapper) ? options.delete(:wrapper) : false,
        wrapper_html: options.delete(:wrapper_html) || {},
        label_html: options.delete(:label_html) || {},
        hint_html: options.delete(:hint_html) || {},
        error_html: options.delete(:error_html) || {}
      }
    end

    def rfk_wrap_field(method, field_html, wrapper_options)
      return field_html unless wrapper_options[:wrapper]

      config = RailsFieldsKit.configuration
      errors = rfk_errors_for(method)
      wrapper_html = wrapper_options[:wrapper_html].dup
      wrapper_html[:class] = [wrapper_html[:class], config.wrapper_class, (config.field_error_class if errors.any?)].compact.join(" ")

      @template.content_tag(:div, wrapper_html) do
        parts = []
        parts << rfk_label(method, wrapper_options[:label], wrapper_options[:label_html]) unless wrapper_options[:label] == false
        parts << field_html
        parts << rfk_hint(wrapper_options[:hint], wrapper_options[:hint_html]) if wrapper_options[:hint]
        parts << rfk_error(errors, wrapper_options[:error_html]) if errors.any?
        parts.join.html_safe
      end
    end

    def rfk_label(method, label_text, label_html)
      label_options = label_html.dup
      label_options[:class] = [label_options[:class], RailsFieldsKit.configuration.label_class].compact.join(" ")
      label(method, label_text, label_options)
    end

    def rfk_hint(hint, hint_html)
      hint_options = hint_html.dup
      hint_options[:class] = [hint_options[:class], RailsFieldsKit.configuration.hint_class].compact.join(" ")
      @template.content_tag(:div, hint, hint_options)
    end

    def rfk_error(errors, error_html)
      error_options = error_html.dup
      error_options[:class] = [error_options[:class], RailsFieldsKit.configuration.error_class].compact.join(" ")
      @template.content_tag(:div, errors.join(", "), error_options)
    end

    def rfk_errors_for(method)
      return [] unless object.respond_to?(:errors) && object.errors.respond_to?(:[])

      Array(object.errors[method]).map(&:to_s).reject(&:empty?)
    end

    def rfk_assign_data_value(data, key, value)
      return if value.nil?
      return if value.respond_to?(:empty?) && value.empty?

      data_key = "rails_fields_kit__tom_select_#{key}_value"
      data[data_key] = value.is_a?(Array) || value.is_a?(Hash) ? JSON.generate(value) : value
    end

    def rfk_choices_with_selected(collection, selected_choices:)
      choices = rfk_normalize_collection(collection)
      existing_values = choices.map { |choice| Array(choice).second.to_s }
      missing_selected_choices = selected_choices.reject { |choice| existing_values.include?(choice.second.to_s) }

      missing_selected_choices + choices
    end

    def rfk_selected_values(selected_choices)
      selected_choices.map(&:second)
    end

    def rfk_normalize_collection(collection)
      case collection
      when nil
        []
      when Hash
        collection.map { |label, value| [label, value] }
      else
        collection
      end
    end

    def rfk_normalize_selected(selected, value_method:, label_method:)
      case selected
      when nil
        []
      when Hash
        [rfk_choice_from_hash(selected)]
      when Array
        selected.flat_map do |item|
          item.is_a?(Array) && item.size == 2 ? [item] : rfk_normalize_selected(item, value_method: value_method, label_method: label_method)
        end
      else
        [[rfk_read_selected_label(selected, label_method), rfk_read_selected_value(selected, value_method)]]
      end
    end

    def rfk_choice_from_hash(selected)
      value = selected[:value] || selected["value"] || selected[:id] || selected["id"]
      label = selected[:text] || selected["text"] || selected[:label] || selected["label"] || selected[:name] || selected["name"] || value

      [label, value]
    end

    def rfk_read_selected_value(record, value_method)
      record.respond_to?(value_method) ? record.public_send(value_method) : record
    end

    def rfk_read_selected_label(record, label_method)
      record.respond_to?(label_method) ? record.public_send(label_method) : record.to_s
    end
  end
end
